public with sharing class zipCode {
  	// Constructor
  	public zipCode() {
        zipValue = 0;
        cityAddr = 'None';
        stateAddr = 'None';
        countryAddr = 'None';
  	}
 
    // Format returned by ziptastic API
    public class ziptasticReturn {
    	string country;
    	string state;
    	string city;
    }
 
    public class zipCodeException extends Exception {}
  
  	// zipValue property is used by VF page and is the zipcode entered by user
	public integer zipValue {
        get { return zipValue; }
        set { zipValue = value; }
	}
    
    // stateAddr is the US state corresponding to the zipValue entered
    public string stateAddr {
    	get { return stateAddr; }
    	private set { stateAddr = value; } 
    }

    // cityAddr is the US city corresponding to the zipValue entered
    public string cityAddr {
    	get { return cityAddr; }
    	private set { cityAddr = value; } 
    }

    // countryAddr is the country corresponding to the zipValue entered
    public string countryAddr {
    	get { return countryAddr; }
    	private set { countryAddr = value; } 
    }
    
  	// This looks up the zip code via REST API
  	//  Returns null so VF page won't navigate to a new page
  	public PageReference lookup() 
  	{
  		string resp;
        
        string ziptasticapiEndpoint ='http://ziptasticapi.com/';
        ziptasticapiEndpoint = ziptasticapiEndpoint + zipValue; 
		ziptasticReturn zipInfo;
		 
		string endpoint = ziptasticapiEndpoint;
    	system.debug(LoggingLevel.Error,'calling endpoint='+endpoint);
    	        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setMethod('GET');
        req.setEndpoint(endpoint);

		try {
	        res = http.send(req);
	        if (res.getStatusCode() != 200) {
	        	throw new zipCodeException(res.getStatus());
	        }
			system.debug(LoggingLevel.Error,'res.body='+res.getBody());
		} catch (zipCodeException e) {
			system.debug(LoggingLevel.Error, 'Error HTTP response code = '+res.getStatusCode()+'; calling '+endpoint );
			return null;
		}

		resp = res.getBody();

		JSONParser parser = JSON.createParser(resp);
		parser.nextToken();		// Start object "{"
		zipInfo = (ziptasticReturn) parser.readValueAs(ziptasticReturn.class);
		
		stateAddr = zipInfo.state;
		cityAddr = zipInfo.city;
		countryAddr = zipInfo.country;
		
/* format from ziptasticapi.com:
{"country":"US","state":"CA","city":"LOS ALTOS"}	
*/		
		return null;
	}
}