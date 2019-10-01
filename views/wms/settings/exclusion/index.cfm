<cfoutput>
<section class="section">
	<div class="container">
		<div class="content">
			<header class="bd-header">
				<div class="bd-header-titles">
					<h1 class="title">Model Exclusions</h1>
					<h5 class="subtitle">
						#linkTo(route = "wmsSettingsBarcodeformat", key = params.barcodeformatkey, text = 'Click here')#
						to edit barcode format data
					</h5>
				</div>
			</header>
		</div>
	</div>
</section>
<section class="section">
	<div class="container">
		<div class="columns">
			<div class="column is-two-thirds">
				<h3 class="title">Excluded Models - <span class="has-text-link">#barcodeformat.name#</span></h3>
				<h5 class="subtitle">Models below will not be selected when printing with the format</h5>
				<div class="box">
					<div class="content">
						<transition name="moveFade" enter-active-class="animated fadeIn" leave-active-class="animated fadeOut" mode="out-in">
							<template v-if="exclusions.length">
								<transition-group name="transitionlist" tag="div" class="field is-grouped is-grouped-multiline" enter-active-class="animated fadeIn" leave-active-class="animated fadeOut" appear>
									<div class="control" v-for="x in exclusions" :key="x.id">
										<div class="tags has-addons">
											<span class="tag is-info is-medium">{{ x.model_number }}</span>
											<span class="tag is-danger is-medium">{{ x.model_name }}</span>
											<a class="tag is-delete is-medium" @click="deleteExclusion(x.id)"></a>
										</div>
									</div>
								</transition-group>
							</template>
							<p class="has-text-centered" v-else>No record</p>
						</transition>	
					</div>
				</div>
			</div>
			<div class="column is-one-third">
				<h3 class="title">Add Model</h3>
				<h5 class="subtitle">Search Model No / Model Name</h5>
				<multiselect 
					v-model="form.model" 
					:options="modelOptions" 
					label="text"
					track-by="model_no"
					@search-change="searchModel"
					@select="selectModel"
					:options-limit="25"
					placeholder="Enter at least 3 characters"
					:close-on-select="true" 
					:clear-on-select="true" 
					:show-labels="false"
					:loading="isLoading"
					:internal-search="false"
					:allow-empty="true"
					:hide-selected="true" 
					:preserve-search="true" 
					placeholder="Pick some" 
					:preselect-first="false" >
				</multiselect>
			</div>
		</div>
	</div>
</section>
</cfoutput>