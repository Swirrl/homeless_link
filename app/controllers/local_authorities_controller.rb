class LocalAuthoritiesController < ApplicationController

  def index

    unless params[:lat] && params[:lon]
      head :bad_request and return
    end

    # 1. get local authority from lat long. Must include ONS code.

    sparql_query = 'PREFIX localgov: <http://opendatacommunities.org/def/local-government/>
      PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
      PREFIX osadmingeo: <http://data.ordnancesurvey.co.uk/ontology/admingeo/>
      PREFIX owl: <http://www.w3.org/2002/07/owl#>

      SELECT ?authority ?os ?lat ?lon ?pythag ?ons ?censusCode ?localAuthLabel where {
        ?authority localgov:governs ?os .
        ?authority rdfs:label ?localAuthLabel .
        ?os geo:lat ?lat .
        ?os geo:long ?lon .
        ?authority osadmingeo:hasCensusCode ?censusCode .
        ?authority owl:sameAs ?ons .
        BIND ( (?lat - (%{lat})) AS ?latdist) .
        BIND ( (?lon - (%{lon})) AS ?londist) .
        BIND ( ((?latdist*?latdist) + (?londist*?londist)) AS ?pythag ) .
      }
      ORDER BY ASC(?pythag)
      LIMIT 1
    '

    url = "http://opendatacommunities.org/sparql.json?query=#{CGI.escape(sparql_query)}&lat=#{params[:lat]}&lon=#{params[:lon]}"

    response = RestClient.get url
    response_hash = JSON.parse( response.body )

    authority = response_hash['results']['bindings'][0]['authority']['value']
    ons = response_hash['results']['bindings'][0]['ons']['value']
    snac = response_hash['results']['bindings'][0]['censusCode']['value']
    local_auth_label = response_hash['results']['bindings'][0]['localAuthLabel']['value']

    # 2. do look up of local authority in our db to get service info.
    services = LocalAuth.where(:snac => snac).first.services

    res = {
      :local_authority => local_auth_label,
      :services => services
    }

    respond_to do |format|
      format.json { render :json => res}
    end
  end

end