module NodeFunctions
  def class_name(node, _)
    node.path.to_a.map(&:camelize).join
  end

  def table_name(node, _)
    node.path.to_a.map(&:underscore).join('_').tableize
  end

  def class_file_name(node, _)
    node.class_name.underscore
  end

  def references(node, selection)
    node.children
    .reject_contained
    .resource_refs
    .by_attr(:embed, nil)
  end

  def belongs_to(node, selection)
    node.ancestors.to_a.sort_by { |n|
      n.path.length
    }.reverse.find do |n|
      n.max == '*' or n.type == 'Resource'
    end
  end

  def resource_ref?(node, _)
    node.path.size > 1 &&
      node.type =~ /^Resource/ &&
      !node.attributes[:embed]
  end

  def has_identity?(node, _)
    node.children.to_a.any? do |child|
      child.name == 'identifier'
    end
  end

  def embedded_associations(node, selection)
    node
    .children
    .reject_contained
    .complex
    .by_attr('max', '*')
  end

  def associations(node, selection)
    nodes = node
    .children
    .reject_contained
    .complex
    .by_attr('max', '*')

    nodes + node.children.map(&:associations).flatten
  end

  def resource_name(node, _)
    node.type.gsub(/^Resource\(/, '').gsub(/\)/, '')
  end

  def referenced_resource(node, selection)
    selection.node([node.resource_name])
  end

  def columns(node, selection)
    singular = node.children.by_attr('max', '1')
    singular.simple.simple_types.reject_idrefs + singular.map(&:columns).flatten
  end

  def serializable_attributes(node, _)
    node.children.simple.by_attr('max', '*')
  end

  def all_serializable_attributes(node, _)
    node.serializable_attributes +
      node.children
      .by_attr('max', '1')
      .map(&:all_serializable_attributes)
      .flatten
  end

  def model_attributes(node, selection)
    node.children.by_attr('max', '1').simple.simple_types.reject_idrefs
  end

  def embedded_children(node, selection)
    node.children.complex.by_attr('max', '1')
  end

  def column_name(node, _, parent)
    postfix = {
      'system' => '_name',
      'type' => '_name'
    }[node.name] || ''

    (node.path - parent.path)
    .to_a.map(&:underscore)
    .join('__').gsub('[x]','') + postfix
  end

  def column_type(node, _)
    {
      'decimal' => 'decimal',
      'integer' => 'integer',
      'boolean' => 'boolean',
      'instant' => 'string',
      'date' => 'date',
      'base64Binary' => 'bytea',
      'string' => 'string',
      'uri' => 'string',
      'dateTime' => 'datetime',
      'id' => 'integer',
      'code' => 'string',
      'oid' => 'string',
      'uuid' => 'string'
    }[node.type] || node.type
  end

end
