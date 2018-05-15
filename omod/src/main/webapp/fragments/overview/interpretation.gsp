<div ng-controller="interpretationController" id = "interpretation">
<div class="info-header">
		<i class="icon-book"></i>
		<h3>Interpretation</h3>
	</div>
	<div class="info-body">
		<div ng-show="visitStatus">
			<form id="new-order" class="sized-inputs css-form" name="newOrderForm" novalidate>
			<br/>
			<div style= "display: inline-block;">
				<p>Rythm:</p>
		    <select style= "display: inline-block;" name="singleSelect" id="singleSelect" ng-model="rythm">
		      <option value="">---Please select---</option> <!-- not selected / blank option -->
		      <option value="Synus">Synus</option> <!-- interpolation -->
		      <option value="AF">AF</option>
					<option value="CBH">CBH</option>
					<option value="1HB">1HB</option>
					<option value="Other">Other</option>
		    </select>
				<p style= "padding-left: 10px;">ECG:</p>
				<select style= "display: inline-block;" name="singleSelect" id="singleSelect" ng-model="ecg">
					<option value="">---Please select---</option> <!-- not selected / blank option -->
					<option value="Recent">Recent</option> <!-- interpolation -->
					<option value="Old - Less than 3 months">Old - Less than 3 months</option>
					<option value="Old - More than 3 months">Old - More than 3 months</option>
				</select><br>
			</div>

				<div>
					<p>ST Depression:</p>
			    <select style= "display: inline-block;" name="singleSelect" id="singleSelect" ng-model="dep">
			      <option value="">---Please select---</option> <!-- not selected / blank option -->
			      <option value="Yes">Yes</option> <!-- interpolation -->
			      <option value="No">No</option>
						<option value="Can't Interpret">Can't Interpret</option>
			    </select>
						<p style= "padding-left: 10px;">ST Elevation:</p>
				    <select style= "display: inline-block;" name="singleSelect" id="singleSelect" ng-model="ele">
				      <option value="">---Please select---</option> <!-- not selected / blank option -->
				      <option value="Yes">Yes</option> <!-- interpolation -->
				      <option value="No">No</option>
							<option value="Can't Interpret">Can't Interpret</option>
				    </select><br>
				</div>

				<div>
					<p>Interpretation:</p>
			    <select style= "display: inline-block;" name="singleSelect" id="singleSelect" ng-model="interpret">
			      <option value="">---Please select---</option> <!-- not selected / blank option -->
			      <option value="Normal ECG">Normal ECG</option> <!-- interpolation -->
			      <option value="Abnormal ECG">Abnormal ECG</option>
						<option value="Can't Interpret">Can't Interpret</option>
			    </select>
					<p style= "padding-left: 10px;">Blood Sugar:</p>
			    <select style= "display: inline-block;" name="singleSelect" id="singleSelect" ng-model="blo_sug">
			      <option value="">---Please select---</option> <!-- not selected / blank option -->
			      <option value="Normal">Normal</option> <!-- interpolation -->
			      <option value="Abnormal">Abnormal</option>
						<option value="Needs HBA1c">Needs HBA1c</option>
						<option value="Needs Further Evaluation">Needs Further Evaluation</option>
			    </select><br>
				</div>

				<div>
					<input type="number" placeholder="Rate" ng-model = "rate">
					<input type="text" placeholder="Axis" ng-model = "axis">
					<input type="text" placeholder="SV2+RV5" ng-model = "wtf">
				</div>
				<br>

			<button type="button" class='btn btn-default' ng-click="addAlert()">Save Interpretation</button>
			<p>{{errortext}}</p>
			<br/>
			</form>
			</div>
			<br>
				<div style= "columns: 2;">
				<div uib-alert ng-repeat="alert in alerts" ng-class="'alert-' + (alert.type || 'info')" close="closeAlert(\$index)">{{alert.msg}}</div>
			</div>
		</div>
		<div>
	</div>
	<br>
</div>

<script>
	var app = angular.module('interpretation', ['recentVisit','EncounterModule']);

	app.controller('interpretationController', function(EncounterFactory, recentVisitFactory, \$scope, \$http, \$timeout){
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
										if(isVital.match("RHPT-Interpretation") !== null) {
											\$scope.encounterUuid = value.uuid;
											var encounterUrl =  "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/encounter/" + \$scope.encounterUuid;
											\$http.get(encounterUrl).then(function(response) {
												angular.forEach(response.data.obs, function(v, k){
													var encounter = v.display;
													\$scope.alerts.push({"msg":v.display, "uuid": v.uuid});
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

		  \$timeout(function () {
		                \$scope.addAlert = function() {
										if(EncounterFactory.rhpt_encounter){

											//Ninja Coding - you have to figure this out yourself :)

											if(\$scope.rythm || \$scope.ele || \$scope.dep || \$scope.ecg || \$scope.blo_sug ||
												\$scope.interpret || \$scope.axis || \$scope.wtf ||  \$scope.rate){

													\$scope.rythmObj = {
														name: 'Rythm: ',
														value: \$scope.rythm,
														conceptId: '7138d10d-8b6e-451c-9902-8d0099e3aa90'
													};
													\$scope.eleObj = {
														name: 'ST Elevation: ',
														value: \$scope.ele,
														conceptId: '26832835-b9bb-4b58-b034-31b63addcd7f'
													};
													\$scope.depObj = {
														name: 'ST Depression: ',
														value: \$scope.dep,
														conceptId: '7ffc9060-0007-48f3-a1a2-b0cfa85b8367'
													};
													\$scope.interpretObj = {
														name: 'Interpretation: ',
														value: \$scope.interpret,
														conceptId: '0b8bc2d5-226d-4a1e-baf8-7d6b0c6534fc'
													};
													\$scope.blo_sugObj = {
														name: 'Blood Sugar: ',
														value: \$scope.blo_sug,
														conceptId: 'f5f4a69f-9ef8-4a93-a2a8-c99fa3dcf4d0'
													};
													\$scope.ecgObj = {
														name: 'ECG: ',
														value: \$scope.ecg,
														conceptId: '503fcb05-e580-4017-8d94-4777c6740374'
													};
													\$scope.axisObj = {
														name: 'Axis: ',
														value: \$scope.axis,
														conceptId: '98be423b-5d0d-4274-a670-c98d81268485'
													};
													\$scope.wtfObj = {
														name: 'SV2+RV5: ',
														value: \$scope.wtf,
														conceptId: '5a77f739-c31a-41ba-901c-ebf68a287747'
													};
													\$scope.rateObj = {
														name: 'Rate: ',
														value: \$scope.rate,
														conceptId: 'cde91479-2ee0-43fb-8757-48ca9ffae21d'
													};

														\$scope.array = [];
														\$scope.array.push(\$scope.rythmObj , \$scope.eleObj , \$scope.depObj , \$scope.ecgObj , \$scope.blo_sugObj ,
															\$scope.interpretObj , \$scope.axisObj, \$scope.wtfObj ,  \$scope.rateObj);

															\$scope.arraynew = [];
															for(i=0;i<\$scope.array.length;i++){
																if(\$scope.array[i].value){
																	\$scope.arraynew.push(\$scope.array[i]);
																}
															}
												}

												for(i=0;i<\$scope.arraynew.length;i++){

														if (\$scope.alerts.indexOf(\$scope.arraynew[i]) == -1){
															\$scope.alerts.push({msg: \$scope.arraynew[i].name + \$scope.arraynew[i].value});
															var url2 = "/" + OPENMRS_CONTEXT_PATH + "/ws/rest/v1/obs";
															\$scope.json = {
																	concept: \$scope.arraynew[i].conceptId,
																	person: patient,
																	obsDatetime: date2,
																	value: \$scope.arraynew[i].value,
																	encounter: EncounterFactory.rhpt_encounter
																}
															var promise = \$http.post(url2, JSON.stringify(\$scope.json)).then(function(response){
																return response;
															});

															promise.then(function (response) {
																\$scope.statuscode = "Success";
																				angular.forEach(\$scope.alerts, function(value, key){
																					if(!value.uuid){
																		\$scope.encounter = value.msg;
																		angular.forEach(\$scope.arraynew, function(v,k){
																			var abc = v.name + v.value;
																			if(\$scope.encounter.match(abc) !== null) {
																			value.uuid = response.data.uuid;
																			}
																		});
																	}
																});
															});

														}
												}
							}
							else {
								alert("If there are multiple reloads, please contact system admin.");
								window.location.reload(true);
							}
		  		};

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
