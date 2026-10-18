# frozen_string_literal: true

require "yaml"
require "set"

ROOT = File.expand_path("..", __dir__)
errors = []

def front_matter(path)
  text = File.read(path, encoding: "UTF-8")
  match = text.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  raise "Missing front matter: #{path}" unless match

  YAML.safe_load(match[1], permitted_classes: [], aliases: false) || {}
end

collections = %w[zh en].to_h do |language|
  records = {}
  Dir.glob(File.join(ROOT, "_#{language}", "*.md")).each do |path|
    metadata = front_matter(path)
    id = metadata["rule_id"]
    if !id.is_a?(String) || !id.match?(/\A[a-z][a-z0-9-]*\z/)
      errors << "Invalid or missing rule_id: #{path}"
      next
    end
    errors << "Missing title: #{path}" if metadata["title"].to_s.strip.empty?
    errors << "Duplicate #{language} identifier: #{id}" if records.key?(id)
    records[id] = path
  end
  [language, records]
end

%w[zh en].each do |language|
  other = language == "zh" ? "en" : "zh"
  (collections[language].keys - collections[other].keys).each do |id|
    errors << "Missing #{other} counterpart: #{id}"
  end
end

referenced = Set.new
pages = Dir.glob(File.join(ROOT, "guideline", "*.md"))
pages.each do |path|
  page = front_matter(path)
  errors << "Missing bilingual layout: #{path}" unless page["layout"] == "bilingual"
  %w[title title_zh title_en permalink chapter].each do |field|
    errors << "Missing #{field}: #{path}" if page[field].to_s.strip.empty?
  end
  ids = Set.new
  previous_level = 1
  rules = page["rules"]
  unless rules.is_a?(Array) && !rules.empty?
    errors << "Missing rules: #{path}"
    next
  end
  rules.each do |rule|
    id = rule["id"]
    errors << "Repeated anchor #{id}: #{path}" unless ids.add?(id)
    referenced.add(id)
    errors << "Missing displayed number #{id}: #{path}" if rule["number"].to_s.empty?
    level = rule["level"]
    unless [2, 3, 4].include?(level)
      errors << "Invalid heading level #{id}: #{path}"
      next
    end
    errors << "Skipped heading level #{id}: #{path}" if level > previous_level + 1
    previous_level = level
    collections.each do |language, records|
      errors << "Unknown #{language} rule #{id}: #{path}" unless records.key?(id)
    end
  end
end
(collections["zh"].keys - referenced.to_a).each { |id| errors << "Unreferenced rule: #{id}" }

abort errors.join("\n") unless errors.empty?
puts "Validated #{pages.length} chapter pages and #{collections['zh'].length} bilingual pairs; heading levels, identifiers, and counterparts are valid."
