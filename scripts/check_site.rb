# frozen_string_literal: true

require "json"
require "uri"
require "cgi"
require "set"
require "yaml"

root = File.expand_path("../_site", __dir__)
abort "Build the site first." unless File.directory?(root)
config = YAML.safe_load(File.read(File.expand_path("../_config.yml", __dir__)))
base = config.fetch("baseurl", "")
errors = []
pages = Dir.glob(File.join(root, "**", "*.html"))
page_ids = pages.to_h do |path|
  ids = File.read(path).scan(/\bid=["']([^"']+)["']/).flatten
  errors << "Duplicate HTML id in #{path}" unless ids.uniq.length == ids.length
  [path, ids.to_set]
end

pages.each do |path|
  html = File.read(path)
  errors << "Unprocessed Liquid: #{path}" if html.match?(/\{%|\{\{/)
  relative = path.delete_prefix(root)
  page_url = base + (relative.end_with?("/index.html") ? relative.delete_suffix("index.html") : relative)
  html.scan(/\b(?:href|src)=["']([^"']*)["']/).flatten.each do |raw|
    href = CGI.unescapeHTML(raw)
    next if href.empty? || href.match?(/\A(?:[a-z][a-z0-9+.-]*:|\/\/)/i)

    uri = URI.join("https://local.invalid#{page_url}", href)
    site_path = URI::DEFAULT_PARSER.unescape(uri.path)
    unless site_path == base || site_path.start_with?(base + "/")
      errors << "Link escapes baseurl: #{href} in #{path}"
      next
    end
    target = File.join(root, site_path.delete_prefix(base))
    target = File.join(target, "index.html") if File.directory?(target)
    unless File.file?(target)
      errors << "Missing link target: #{href} in #{path}"
      next
    end
    if uri.fragment && !uri.fragment.empty? && target.end_with?(".html")
      fragment = URI::DEFAULT_PARSER.unescape(uri.fragment)
      errors << "Missing anchor: #{href} in #{path}" unless page_ids.fetch(target, Set.new).include?(fragment)
    end
  rescue URI::InvalidURIError => error
    errors << "Invalid link #{href}: #{error.message}"
  end
end

index = JSON.parse(File.read(File.join(root, "search-index.json")))
errors << "Search index is empty" if index.empty?
index.each do |entry|
  %w[id number zh_title en_title zh_text en_text url].each do |key|
    errors << "Missing search field #{key} for #{entry['id']}" if entry[key].to_s.empty?
  end
end
%w[AGENTS.md Gemfile Gemfile.lock scripts source original-documents].each do |private_path|
  errors << "Development or source file published: #{private_path}" if File.exist?(File.join(root, private_path))
end

abort errors.join("\n") unless errors.empty?
puts "Checked #{pages.length} HTML pages, their local links and anchors, source exclusions, and #{index.length} search records."
