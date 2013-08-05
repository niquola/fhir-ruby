class Rules
  def self.apply(graph)
    graph.rule(%w[MedicationStatement dosage site coding],  max: '1')
    graph.rule(%w[MedicationStatement dosage route coding], max: '1')
    graph.rule(%w[MedicationStatement dosage method coding], max: '1')
    graph.rule(%w[MedicationStatement identifier], max: '1')
    graph.rule(%w[MedicationStatement reasonNotGiven coding], max: '1')
    graph.rule(%w[MedicationStatement medication], max: '1', embed: true)
    graph.rule(%w[MedicationStatement medication package], max: '0')
    graph.rule(%w[MedicationStatement medication package], max: '0')
    graph.rule(%w[MedicationStatement medication product], max: '0')
    graph.rule(%w[AllergyIntolerance recorder], type: 'Resource(Practitioner)', embed: true)
    graph.rule(%w[Condition asserter], type: 'Resource(Practitioner)', embed: true)
    graph.rule(%w[MedicationStatement medication product ingredient item], type: 'Resource(Medication)')
  end
end
