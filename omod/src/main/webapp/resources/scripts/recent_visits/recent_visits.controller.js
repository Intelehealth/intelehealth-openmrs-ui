recentVisits.filter('vitalsDate', function() {
	return function(text) {
		 text = text || "";
		 var str = text;
		 str = str.substr(7,str.length);
		 var date = str.substr(3,2);
		 date = date + "/" + str.substr(0,3) + str.substr(7,4);
		 var newDate =new Date(date);
		 return newDate;
	 };
 });
 
 recentVisits.filter('round', function(){
	 return function(x){
		   return x.toFixed(1);
	 };
 });

 
 recentVisits.controller('recentVisitController', function($scope, $http,
		 $timeout, recentVisitFactory, $location) {
	 var observation = {}
	 $scope.recentVisits = [];
	 $scope.visitList = [];
	 $scope.visitDetails = {};
	 $scope.vitaluuid = [];
	 $scope.vitalsData = [];
	 $scope.vitalsPresent =true;
	 $scope.patientId = window.location.search.split('=')[1];
	 recentVisitFactory.fetchRecentVisit($scope.patientId).then(function(data) {
				 $scope.visitList = data.data.results;
				 $scope.links = [];
				 angular.forEach($scope.visitList, function(value, key) {
					 if($scope.patientId === value.patient.uuid){
						 var uuid = value.uuid;
						  $scope.uuid6 = value.uuid;
						 $scope.vitaluuid.push(value.uuid);
						 recentVisitFactory.fetchVisitDetails(uuid).then(function(data) {
							  $scope.visitDetails = data.data;
							  recentVisitFactory.fetchVisitEncounterObs(data.data.uuid).then(function(data) {
								var enc = data.data.encounters
								for (var p = 0; p<enc.length ; p++){
									var disp = enc[p].display
									if (disp.match("ADULTINITIAL") !== null ){
										$scope.visitDetails = enc[p].obs;
										angular.forEach($scope.visitDetails, (v) => {
										var display = v.display
											if (display.match("CURRENT COMPLAINT") !== null) {
												var obs = display.split('<b>');
												var b = " "
													for (var i = 1; i<obs.length; i++) {
														var obs1 = obs[i].split('<')
														var b = b + " | " + obs1[0]
														value.observation = b
													}
												}
										})
									}
								}
						
						 })
							 if ($scope.visitDetails.stopDatetime == null || $scope.visitDetails.stopDatetime == undefined) {
								 value.visitStatus = "Active";
							 }
							 $scope.recentVisits.push(value);	
						 }, function(error) {
							 console.log(error);
						 });
						 	
					 }
					 
				 });
				  
				 // RECENT VITALS
				 if($scope.vitaluuid){
					 let recent = $scope.vitaluuid[0];
					 recentVisitFactory.fetchVisitDetails(recent).then(function(data) {
						 let encounter = data.data.encounters;
						 if(encounter) {
							 $scope.vitalsPresent = true;
						 angular.forEach(encounter, function(v,k){
							 var isVital = v.display;
							 if (isVital.match("Vitals") !== null) {
								 var encounterUuid = v.uuid;
								 var encounterUrl =  "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter/" + encounterUuid;
								 $http.get(encounterUrl).then(function(response){
									 let obs = [];
									 var answers = {date:response.data.display, temperature:'-', height:'-', weight:'-', bmi:'-',
									 o2sat:'-', systolicBP:'-', diastolicBP: '-', pulse: '-'};
									 obs.push(response.data.obs);
									 angular.forEach(response.data.obs, function(value,key){
											 if(value.display.includes('TEMP')){
												 answers.temperature = Number(value.display.slice(17,value.display.length));
											 }
						 if(value.display.includes('Height')){
								 answers.height = Number(value.display.slice(13,value.display.length));
						 }
						 if(value.display.includes('Weight')){
								 answers.weight = Number(value.display.slice(13,value.display.length));
						 }
						 if(value.display.includes('BLOOD OXYGEN')){
								 answers.o2sat = Number(value.display.slice(25,value.display.length));
						 }
						 if(value.display.includes('SYSTOLIC')){
								 answers.systolicBP = Number(value.display.slice(25,value.display.length));
						 }
						 if(value.display.includes('DIASTOLIC')){
								 answers.diastolicBP = Number(value.display.slice(26,value.display.length));
						 }
						 if(value.display.includes('Pulse')){
								 answers.pulse = Number(value.display.slice(7,value.display.length));
						 }
									 })
 
									 $scope.vitalsData.push(answers);
								 }, function(error){
									 console.log("Error");
								 });
							 }
						 });
					 }
					 else{
						 $scope.vitalsPresent = false;
					 }
					 }, function(error) {
						 console.log(error);
					 })
				 }
				 else{
 
				 }
			 }, function(error) {
				 console.log(error);
			 });
});