module Fhir
  module TemplateFunctions
    def template(selection, opts = {}, &block)
      opts = {attr_to_write: :template_result}.merge(opts)
      path = opts[:path]
      template_str = block_given? ? block.call : File.read(path)
      template = ERB.new(template_str, nil, '%<>-')
      template.filename = path if path
      selection.select do |node|
        node.attributes[opts[:attr_to_write]] = template.result(binding)
      end
    end

    def render(selection, indent = 0, attr_to_read = :template_result)
      spaces = '  '*indent
      selection
      .to_a
      .map { |e| e.attributes[attr_to_read].gsub(/^(.+)$/, "#{spaces}\\1") }
      .join("\n")
    end

    def file(selection, folder_path, attr_to_read = :template_result, &block)
      FileUtils.mkdir_p(folder_path)
      selection.to_a.each do |node|
        content = node.attributes[attr_to_read]
        file_name = block.call(node)
        File.open(File.join(folder_path, file_name), 'w') { |f| f<< content }
      end
      selection
    end
  end
end
