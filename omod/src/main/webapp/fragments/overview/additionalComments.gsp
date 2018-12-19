<div id="comments" class="long-info-section" ng-controller="intelehealthAdditionalCommentsController">
	<div class="info-header">
		<i class="icon-comments"></i>
		<h3>Doctor's Note</h3>
	</div>
	<div class="info-body" ng-cloak>
  <br>
			<textarea row="3" cols="50" class="comments" ng-show="visitStatus" type="text" ng-model="addMe" class="form-control"></textarea>
			<button ng-show="visitStatus" type="button" class='btn btn-default' ng-click="addAlert()">Add Note</button>
			<p>{{errortext}}</p>
			<br/>
			<br/>
			<div uib-alert ng-repeat="alert in alerts" ng-class="'alert-' + (alert.type || 'info')" close="closeAlert(\$index)">{{alert.msg}}</div>
	</div>
  <br>
</div>



<script>
// This file has common documentation for all fragments because they all share the common concepts unless documented!
var app = angular.module('additionalComments', ['ngAnimate', 'ngSanitize', 'recentVisit', 'EncounterModule']);

// These factories are used for fetching dropdown data. GETing data by calling concept endpoints.
app.factory('additionalCommentsFactory', function(\$http){
  var testurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/concept/" + window.constantConfigObj.conceptAdditionalComments;
  return {
    async: function(){
      return \$http.get(testurl).then(function(response){
	var data = [];
	angular.forEach(response.data.answers, function(value, key){
	  data.push(value.display);
	});
        return data;
      });
    }
  };
});

app.controller('intelehealthAdditionalCommentsController', function(\$scope, \$http, \$timeout, EncounterFactory, additionalCommentsFactory, recentVisitFactory) {
  \$scope.alerts = [];
  \$scope.respuuid = [];
  var _selected;
  var patient = "${ patient.uuid }";
  var date2 = new Date();

var path = window.location.search;
var i = path.indexOf("visitId=");
var visitId = path.substr(i + 8, path.length);
\$scope.visitEncounters = [];
\$scope.visitObs = [];
\$scope.visitNoteData = [];
\$scope.visitNotePresent = true;
\$scope.visitStatus = false;
\$scope.encounterUuid = "";
//Search Existing Obs
recentVisitFactory.fetchVisitEncounterObs(visitId).then(function(data) {
						\$scope.visitDetails = data.data;
							if (\$scope.visitDetails.stopDatetime == null || \$scope.visitDetails.stopDatetime == undefined) {
								\$scope.visitStatus = true;
							}
							else {
								\$scope.visitStatus = false;
							}
						\$scope.visitEncounters = data.data.encounters;
						if(\$scope.visitEncounters.length !== 0) {
						\$scope.visitNotePresent = true;
							angular.forEach(\$scope.visitEncounters, function(value, key){
								var isVital = value.display;
								if(isVital.match("Visit Note") !== null) {
									\$scope.encounterUuid = value.uuid;
									var encounterUrl =  "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter/" + \$scope.encounterUuid;

									\$http.get(encounterUrl).then(function(response) {
										angular.forEach(response.data.obs, function(v, k){
											var encounter = v.display;
											//Matches response for "additionalComments" and slice to get rid of additionalComments
											if(encounter.match("Additional Comments") !== null) {
											\$scope.alerts.push({"msg":v.display.slice(21,v.display.length), "uuid": v.uuid});

											}
										});
									}, function(response) {
										\$scope.error = "Get Encounter Obs Went Wrong";
								    	\$scope.statuscode = response.status;
								    });
								}
							});
						}
						else {
							\$scope.visitNotePresent = false;
						}
					}, function(error) {
						console.log(error);
					});


 //calling the factory and handling promise
  var promiseTests = additionalCommentsFactory.async().then(function(d){
	return d;
  });

  promiseTests.then(function(x){
	\$scope.testlist = x;
  })

  \$timeout(function () {
		//Adds new obs
                \$scope.addAlert = function() {
									// Run obs post code only if encounter value is available else reload page
									if(EncounterFactory.encounterValue) {
                        \$scope.errortext = "";
												//if nothing in input and user clicks enter
                        if (!\$scope.addMe) {
                                \$scope.errortext = "Please enter text.";
                                return;
                        }
    			if (\$scope.alerts.indexOf(\$scope.addMe) == -1){
						//new obs being pushed to array
    				\$scope.alerts.push({msg: \$scope.addMe})
    				var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs";
    				\$scope.json = {
         				concept: window.constantConfigObj.conceptAdditionalComments,
         				person: patient,
         				obsDatetime: date2,
         				value: \$scope.addMe,
         				encounter: EncounterFactory.encounterValue
        			}
    				\$http.post(url2, JSON.stringify(\$scope.json)).then(function(response){
        				if(response.data) {
                				\$scope.statuscode = "Success";
                				angular.forEach(\$scope.alerts, function(v, k){
										var encounter = v.msg;
										//saving uuid of obs to alerts array for deletion purposes
										if(encounter.match(\$scope.addMe) !== null) {
										v.uuid = response.data.uuid;
										}
								});
								\$scope.addMe = "";
                        }
    				}, function(response){
                			\$scope.statuscode = "Failed to create Obs";
    				});
    			}
				}
				//This executes if encounter has not been created
				else {
					alert("If there are multiple reloads, please contact system admin.");
					window.location.reload(true);
				}
  		};
				//delete the array, index is index of particular obs in array and using its uuid to purge that obs
	  		\$scope.closeAlert = function(index) {
	  			if (\$scope.visitStatus) {
		    		var deleteurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs/" + \$scope.alerts[index].uuid + "?purge=true";
					\$http.delete(deleteurl).then(function(response){
					\$scope.alerts.splice(index, 1);
 			        		\$scope.errortext = "";
						\$scope.statuscode = "Success";
					}, function(response){
						\$scope.statuscode = "Failed to delete Obs";
					});
				}
	  		};
  }, 5000);

});
</script>
