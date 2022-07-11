utils = require 'mp.utils'
require 'mp.options'
require 'os'
require 'io'
require 'string'

local options = {
    directory = ".",
    ratings_file = "RBS-ratings.txt",
}
read_options(options, "ratings-based-shuffle")

all_files = {}
ratings = {}

function init_rbs()
    auto_add_file()
end

function load(path)
    for idx, name in ipairs(utils.readdir(path, "dirs")) do
        print(path .. "/" .. name)
        load(utils.join_path(path, name))
    end
    for idx, name in ipairs(utils.readdir(path, "files")) do
        print(path .. "/" .. name)
        table.insert(all_files, utils.join_path(path, name))
    end
end

function load_ratings(path)
    info = utils.file_info(path)
    if info == nil then
        -- nothing to read
    elseif info.is_file then
        file = io.open(path, "r")
        io.input(file)
        ratings, err = utils.parse_json(io.read())
        io.close(file)
    else
        msg.warn("could not load ratings")
    end
end

function save_ratings(path)
    info = utils.file_info(path)
    if info == nil or info.is_file then
        file = io.open(path, "w")
        io.output(file)
        json, err = utils.format_json(ratings)
        io.write(json)
        io.close(file)
    else
        msg.error("could not save ratings")
    end
end

function upvote()
    file = mp.get_property("path")
    print(file)
    if ratings[file] == nil then
        ratings[file] = 0.5
    else
        ratings[file] = ratings[file] + 0.5
    end
    mp.osd_message("Rating: " .. tostring(ratings[file]))
    save_ratings(options.ratings_file)
end

function downvote()
    file = mp.get_property("path")
    if ratings[file] == nil then
        ratings[file] = 0.0
    else
        ratings[file] = ratings[file] - 0.5
    end
    mp.osd_message("Rating: " .. tostring(ratings[file]))
    save_ratings(options.ratings_file)
end

-- https://stackoverflow.com/q/2282444/5013267
function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end

function auto_add_file(event)
    -- get all_files from ratings
    for file, rating in pairs(ratings) do
        if not table.contains(all_files, file) then
            table.insert(all_files, file)
        end
    end
     
    -- randomly add a file from all_files according to its rating (higher rating = more likely to be added)
    -- if the file is already in the playlist, it will not be added again
    -- a file in all_files has a corresponding rating value ratings[file]
    print("auto_add_file")

    -- return if the playlist is empty
    if #all_files == 0 then
        mp.osd_message("No files to add")
        return
    end
    
    -- weighted random selection
    -- the sum of all ratings is the total weight of the selection
    -- the selection is made by adding a random number between 0 and the total weight of the selection
    totalSum = 0.0
    for _, file in ipairs(all_files) do
        totalSum = totalSum + ratings[file]
    end
    random = math.random() * totalSum
    print("totalSum: " .. tostring(totalSum))
    print("random: " .. tostring(random))
    sum = 0.0
    for _, file in ipairs(all_files) do
        sum = sum + ratings[file]
        print("sum: " .. tostring(sum))
        if sum >= random then
            print("adding file: " .. file)
            mp.commandv("loadfile", file, "append")
            mp.commandv("playlist-next")
            mp.osd_message("Selected: " .. file .. "\nRating: " .. tostring(ratings[file]))
            break
        end
    end
end

math.randomseed(math.sin(os.time())*10000)
load_ratings(options.ratings_file)
mp.register_script_message("RBS-init", init_rbs)
mp.register_script_message("RBS-upvote", upvote)
mp.register_script_message("RBS-downvote", downvote)
