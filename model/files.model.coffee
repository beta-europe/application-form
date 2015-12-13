@Files = new FS.Collection 'files',
  stores: [
    # new FS.Store.GridFS("original")
    # https://github.com/CollectionFS/Meteor-CollectionFS/tree/devel/packages/filesystem
    new FS.Store.FileSystem 'original'
  ]
  filter:
    allow:
      contentTypes: ['image/*']



Files.allow
  insert: (userId, file) ->
    true
  update: (userId, file, fields, modifier) ->
    false
  remove: (userId, file) ->
    fales
