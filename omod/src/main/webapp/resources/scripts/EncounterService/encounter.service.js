encounterService.factory('EncounterFactory', ['$http', '$filter',function( $http, $filter ){
    var str = window.location.search.split('=')[1];
    var patient = str.split('&')[0];
    var url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter";
    url += "?patient=" + patient;
    url += "&encounterType=" + "d7151f82-c1f3-4152-a605-2f9ea7414a79";
    var testurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/session"; //To get encounter provider value
    return{
      //Used to get encounter Value
      getEncounter: function(){
          return $http.get(url).then(function(response){
          return response.data.results;
        });
      },
      //Used to post a new encounter of type VISITNOTE
      postEncounter: function(){
          return $http.get(testurl).then(function(response){
          return response.data.user.uuid;
        });
      },
//Object to store encounter uuid in the entire page, call this by including this factory and
//calling EncounterFactory.encounterValue
      encounterValue: ''

    };
  }
]);
