<div style = "padding-top: 7px;" id="vitals" class="long-info-section" ng-controller = "recentVisitController">
	<div class="info-header">
		<i class="icon-vitals"></i>
		<h3>Vitals</h3>
	</div>
	<div class="info-body" ng-cloak>
				<div ng-repeat = "item in vitalsData">
					<div class= "title">
						Last Vitals: {{item.date | vitalsDate | date: 'dd/MM/yyyy'}}
						<br>
					</div>
					<span ng-if="!item.temperature.includes('-')">Temp: {{item.temperature | number:2}} C</span>
					<span ng-if="item.temperature.includes('-')">Temp: {{item.temperature}} </span>
						<div>
							Height: {{item.height}} cm
							<br>
						</div>
							<div>
								Weight: {{item.weight}} kg
								<br>
							</div>
								<div ng-if = "item.weight.includes('-') || item.height.includes('-')">
									BMI: {{item.bmi}}
									<br>
								</div>
									<div ng-if = "!item.weight.includes('-') && !item.height.includes('-')">
										BMI: {{item.weight/((item.height/100)*(item.height/100)) | round}}
										<br>
									</div>
											<div>
												SP02: {{item.o2sat}} %
												<br>
											</div>
												<div>
													BP: {{item.systolicBP}} / {{item.diastolicBP}}
													<br>
												</div>
													<div>
														HR: {{item.pulse}}
														<br>
													</div>
				</div>
	</div>
</div>