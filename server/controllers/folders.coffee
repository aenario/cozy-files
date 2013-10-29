Folder = require '../models/folder'
File = require '../models/file'


## Helpers ##

findFolder = (id, callback) ->
    Folder.find id, (err, file) =>
        if err or not file
            callback "File not found"
        else
            callback null, file 

## Actions ##

module.exports.create = (req, res) ->
    Folder.all (err, folders) ->
        conflict = false
        for folder in folders
            if folder.slug is req.body.slug
                conflict = true
                res.send error:true, msg: "This folder already exists", 400
        if not conflict
            Folder.create req.body, (err, newFolder) ->
                if err
                    res.send error: true, msg: "Server error while creating file.", 500
                else    
                    res.send newFolder, 200

module.exports.find = (req, res) ->
    findFolder req.params.id, (err, folder) ->
        if err
            res.send error: true, msg: err, 404
        else   
            res.send folder, 200

module.exports.findFoldersRoot = (req, res) ->
    Folder.byFolder (err, folders) ->
        if err
            res.send error: true, msg: "Server error occured", 500
        else
            # pb : change !!!
            result = []
            for folder in folders
                if folder.path is ''
                    result.push folder
            res.send result, 200


module.exports.findFilesRoot = (req, res) ->
    File.byFolder (err, files) ->
        if err
            res.send error: true, msg: "Server error occured", 500
        else
            # pb : change !!!
            result = []
            for file in files
                if file.path is ''
                    result.push file
            res.send result, 200

module.exports.findFiles = (req, res) ->
    findFolder req.params.id, (err, folder) ->
        if err
            res.send error: true, msg: err, 404
        else
            File.byFolder key: folder.slug ,(err, files) ->
                if err
                    res.send error: true, msg: "Server error occured", 500
                else
                    res.send files, 200 

module.exports.findFolders = (req, res) ->
    findFolder req.params.id, (err, folder) ->
        if err
            res.send error: true, msg: err, 404
        else
            Folder.byFolder key: folder.slug ,(err, folders) ->
                if err
                    res.send error: true, msg: "Server error occured", 500
                else
                    res.send folders, 200


module.exports.destroy = (req, res) ->
    findFolder req.params.id, (err, currentFolder) ->
        if err
            res.send error: true, msg: err, 404
        else
            # Remove folders in the current folder
            Folder.all (err, folders) =>
                if err
                    res.send error: true, msg:  "Server error occured", 500
                else
                    for folder in folders
                        if (folder.path.indexOf(currentFolder.slug) is 0)
                            folder.destroy (err) ->
                                console.log err if err
                    # Remove files in the current folder
                    File.all (err, files) =>
                        if err
                            res.send error: true, msg:  "Server error occured", 500
                        else
                            for file in files
                                if (file.path.indexOf(currentFolder.slug) is 0)
                                    file.destroy (err) ->
                                        console.log err if err
                             # Remove the current folder
                            currentFolder.destroy (err) ->
                                if err
                                    compound.logger.write err
                                    res.send error: 'Cannot destroy folder', 500
                                else
                                    res.send success: 'Folder succesfuly deleted', 200