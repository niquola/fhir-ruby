class Rules
  def self.apply(graph)
    graph.rule(%w[MedicationStatement dosage site coding],  max: '1')
    graph.rule(%w[MedicationStatement dosage route coding], max: '1')
    graph.rule(%w[MedicationStatement dosage method coding], max: '1')
    graph.rule(%w[MedicationStatement identifier], max: '1')
    graph.rule(%w[MedicationStatement reasonNotGiven coding], max: '1')
    # graph.rule(%w[MedicationStatement medication], max: '1', embed: true)
  end
end
