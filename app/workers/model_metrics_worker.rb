class ModelMetricsWorker
  include Sidekiq::Worker

  DATASET_LABELS = %i{topics.name dataset_type licence_code frequency organisations.name frequency}.freeze
  DATASET_QUERY = Dataset.joins(:topic).joins(:organisation).group(DATASET_LABELS)

  LINK_LABELS = %i{format type}.freeze
  LINK_QUERY = Link.group(LINK_LABELS)

  USER_LABELS = %i{organisation_slug}.freeze
  USER_QUERY = User.group(USER_LABELS)

  def perform
    export_metrics(USER_QUERY, USER_LABELS)
    export_metrics(LINK_QUERY, LINK_LABELS)
    export_metrics(DATASET_QUERY, DATASET_LABELS)
  end

private

  def export_metrics(query, label_names)
    gauge = find_or_initialize_gauge(query)

    query.count.each do |label_values, count|
      labels = label_names.zip(normalize(label_values))
      gauge.set(Hash[labels], count)
    end
  end

  def normalize(label_values)
    Array(label_values).map(&:to_s).map(&:downcase)
  end

  def metric_name(query)
    model_name = query.model.name.to_s.downcase
    "datagovuk_publish_#{model_name}_total".to_sym
  end

  def find_or_initialize_gauge(query)
    registry = Prometheus::Client.registry

    registry.get(metric_name(query)) ||
      registry.gauge(metric_name(query), '...')
  end
end
