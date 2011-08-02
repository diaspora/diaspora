class NewRelic::MetricParser::Solr < NewRelic::MetricParser::MetricParser

  def short_name
    if segments[1] == "org.apache.solr.search.SolrIndexSearcher"
      "SolrIndexSearcher"
    elsif segments[1] =~ /org\.apache\.solr\.handler\.component/
      segments[1].split(".")[-1]
    else
      super
    end
  end

  def legend_name
    if all?
      'Solr'
    else
      super
    end
  end

  def category; 'Solr Query'; end

  private
  def all?
    name == Metric::SOLR_ALL_WEB
  end
end
