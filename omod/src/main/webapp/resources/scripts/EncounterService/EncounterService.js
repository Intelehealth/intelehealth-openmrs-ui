var EncounterServices = angular.module('EncounterService', []);

EncounterServices.factory('EncounterServices', ['$http', '$filter',function( $http, $filter ){
  var path = window.location.search;
  var i = path.indexOf("patient=");
  var patientId = path.substr(i + 12, path.length);
  var date = new Date();
  date = $filter('date')(new Date(), 'yyyy-MM-dd');
  var url = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter";
      url += "?patient=" + patientId;
      url += "&encounterType=" + "d7151f82-c1f3-4152-a605-2f9ea7414a79";
      url += "&fromdate=" + date;
  var testurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/session";
  return{
    getEncounter: function(){
      return $http.get(url).then(function(response){
      return response.data.results;
      });
    },

    postEncounter: function(){
      return $http.get(testurl).then(function(response){
      return response.data.user.uuid;
    });
  }
};
}
]);
