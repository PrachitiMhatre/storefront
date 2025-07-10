if Rails.env.development?
  Elasticsearch::Model.client = Elasticsearch::Client.new(
    url: 'http://localhost:9200',
    log: true
  )
end
