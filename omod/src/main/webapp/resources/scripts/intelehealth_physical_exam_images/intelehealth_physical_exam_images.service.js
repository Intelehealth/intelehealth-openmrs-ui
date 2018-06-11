intelehealthPhysicalExamination.factory('intelehealthPhysicalExaminationFactory', [ '$http', '$q',
		function($http, $q) {
			return {
				fetchPhysicalExamination : function(patientUuid, visitId) {
					var url = "http://162.243.160.40:1337/parse/classes/PhysicalExam?where={\"PatientID\":\"" + patientUuid +"\",\"VisitID\":\"" + visitId + "\"}";
					var headers = {headers:  {
				        'X-Parse-Application-Id': 'app2',
				        'X-Parse-REST-API-Key': 'undefined'
							}
						};
					return $http.get(url, headers);
				}
			};
		}]);
