<div ng-controller="Ctrl" id = "followup">
<div class="info-header">
		<i class="icon-book"></i>
		<h3>Follow Up</h3>
	</div>
	<div class="info-body">
		<br/>
		<div>
		        <input type="text" b-datepicker ng-model="followup_date" placeholder="Follow Up Date"/>
		        <button type="button" class="btn" data-toggle="datepicker"> <i class="icon-calendar"></i>
		        </button>
				<input type="text" style = 'margin-top : 10px; margin-left : 10px;' ng-model = 'advice'placeholder="Follow Up Advice">
				<button type="button" ng-click = 'addtype()' ng-show = "alerts.length == 0">Schedule a Follow Up</button>
				{{errortext}}
				<br>
				<br/>
				<div uib-alert ng-repeat="alert in alerts" ng-class="'alert-' + (alert.type || 'info')" close="closeAlert(\$index)">{{alert.msg}}</div>
		</div>
		</div>
		<div>
		<p>*please delete current schedule to schedule a new follow up.</p>
	</div>
</div>
<script>
var myApp = angular.module('FollowUp', ['recentVisit', 'ngAnimate', 'ngSanitize', 'EncounterModule']);

myApp.directive('bDatepicker', function () {
    return {
        restrict: 'A',
        link: function (scope, el, attr) {
            el.datepicker({
							minDate: 0,
							dateFormat: 'dd-mm-yy'
						});
            var component = el.siblings('[data-toggle="datepicker"]');
            if (component.length) {
                component.on('click', function () {
                    el.trigger('focus');
                });
            }
        }
    };
});

myApp.controller('Ctrl', function(\$scope, \$http, \$timeout, EncounterFactory, recentVisitFactory){
		var patient = "${patient.uuid}";
		\$scope.alerts = [];
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
		\$scope.isDiasbled = false;
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
								if(encounter.match("Follow up visit") !== null) {
									\$scope.alerts.push({"msg":v.display.slice(16,v.display.length), "uuid": v.uuid});
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

			\$timeout(function (){
			\$scope.addtype = function(){
				if(EncounterFactory.encounterValue){

				\$scope.followup = \$scope.followup_date;
				if(\$scope.advice){
					\$scope.followup += ', Advice: ' + \$scope.advice;
				}
				\$scope.errortext = "";
				if (!\$scope.followup_date) {
								\$scope.errortext = "Please enter text.";
								return;
				}
				if (\$scope.alerts.indexOf(\$scope.followup) == -1){
								\$scope.alerts.push({msg: \$scope.followup})
								  var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs";
											\$scope.json = {
															concept: 'e8caffd6-5d22-41c4-8d6a-bc31a44d0c86',
															person: patient,
															obsDatetime: date2,
															value: \$scope.followup,
															encounter: EncounterFactory.encounterValue
											}
											\$scope.followup_date = '';
											\$scope.advice = '';
											\$http.post(url2, JSON.stringify(\$scope.json)).then(function(response){
												if(response.data){
																\$scope.statuscode = "Success";
																angular.forEach(\$scope.alerts, function(v, k){
									var encounter = v.msg;
									if(encounter.match(\$scope.followup) !== null) {
									v.uuid = response.data.uuid;
									}
								});
								\$scope.followup = "";
														}
											}, function(response){
												\$scope.statuscode = "Failed to create Obs";
											});
				}
			}
			else {
				alert("If there are multiple reloads, please contact system admin.");
				window.location.reload(true);
			}
};
			\$scope.closeAlert = function(index) {
	  		if (\$scope.visitStatus) {
					\$scope.isDiasbled = false;
				\$scope.deleteurl = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs/" + \$scope.alerts[index].uuid + "?purge=true";
	                	\$http.delete(\$scope.deleteurl).then(function(response){
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
