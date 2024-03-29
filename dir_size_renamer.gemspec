Gem::Specification.new do |s|
  s.name          = 'dir_size_renamer'
  s.version       = '0.0.4'
  s.date          = '2012-04-25'
  s.summary       = "DirSizeRenamer"
  s.description   = "This console utility lets you rename subdirectories within a specified directory, so that subdirectories' names contain their sizes."
  s.authors       = ["Andrey 'lolmaus' Mikhaylov"]
  s.email         = 'lolmaus@gmail.com'
  s.files         = Dir["{lib}/*.rb", "bin/*", "*.md"]
  s.homepage      = "https://github.com/lolmaus/dir_size_renamer"
  s.bindir        = 'bin'
  s.executables   << 'dir_size_renamer'
  s.add_runtime_dependency "slop"
  s.add_runtime_dependency "chronic_duration"
end