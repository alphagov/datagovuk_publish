Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "url_builder" => "URLBuilder",
  )
end
