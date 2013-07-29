module SelectionFunctions
  def reject_idrefs(selection)
    selection.select do |n|
      n.type != 'xmlIdRef'
    end
  end

  def reject_contained(selection)
    selection.select do |n|
      n.name != 'contained'
    end
  end

  def simple_types(selection)
    selection.select do |n|
      n.type =~ /^[a-z].*/
    end
  end

  def sorted(selection)
    selection.sort_by(&:path)
  end

  def tables(selection)
    (selection.by_attr('type', 'Resource') + selection.by_attr('max', '*')).sorted
  end

  def models(selection)
    selection.tables
  end

  def resource_refs(selection)
    selection.select(&:resource_ref?)
  end
end
