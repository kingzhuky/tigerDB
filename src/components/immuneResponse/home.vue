<template>
  <div id="tigtable">
    <el-card class="box-card-heatmap">
      <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="tigtable">
        <el-tab-pane label="Differential Expression Analysis" name="diffexp">
          <component :is="diffexpVue"></component>
        </el-tab-pane>

        <!-- <el-tab-pane label="Pathway Enrichment Analysis" name="pathway">
          <component :is="pathwayVue"></component>
        </el-tab-pane> -->

        <el-tab-pane label="Survival Analysis" name="survival">
          <component :is="survivalVue"></component>
        </el-tab-pane>

        <el-tab-pane label="Gene Set Query" name="signature">
          <component :is="signatureVue"></component>
        </el-tab-pane>

        <!-- <el-tab-pane label="Dataset Overview" name="overview">
          <component :is="dataOverviewVue"></component>
        </el-tab-pane> -->

      </el-tabs>
    </el-card>
  </div>
</template>

<script>
const wersurvival = resolve => require(["./survival.vue"], resolve);
const werdiffexp = resolve => require(["./expression/home.vue"], resolve);
const wersignature = resolve => require(["./signature.vue"], resolve);
const diffpathway = resolve => require(["./pathway.vue"], resolve);
const dataoverview = resolve => require(["./datasetoverview.vue"], resolve);
//import { hsv2rgb, gStyle } from "../../../static/js/utils.js";

export default {
  data() {
    return {
      activeName: "diffexp",
      diffexpVue: "",
      survivalVue: "",
      signatureVue: "",
      pathwayVue: "",
      dataOverviewVue: "",
    };
  },
  created() {
    this.diffexpVue = werdiffexp;
  },

  methods: {
    handleClick(tab, event) {
      this.checkVue(tab.name);
    },
    checkVue(name) {
      switch (name) {
        case "diffexp":
          this.diffexpVue = werdiffexp;
          break;
        case "pathway":
          this.pathwayVue = diffpathway;
        case "survival":
          this.survivalVue = wersurvival;
          break;
        case "signature":
          this.signatureVue = wersignature;
          break;
        case "overview":
          this.dataOverviewVue = dataoverview;
          break;
      }
    }
  }
};
</script>

<style>
div#tigtable {
  margin-bottom: 20px;
}

#tab-diffexp,
#tab-pathway,
#tab-survival,
#tab-overview,
#tab-signature {
  font-size: 20px;
  height: 55px;
  padding: 10px;
  font-weight: bold !important;
}

.box-card-heatmap {
  width: 1380px;
  margin: 0 auto;
}
.info {
  width: 1350px;
}

#survivaltable th,#therapyTable th, #responseTable th {
  left: 135px !important;
  height: 270px !important;
}


</style>
