<template>
  <div id="wertab">
    <el-card class="box-card-heatmap">
      <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="werTab">
        <el-tab-pane label="Differential Expression Analysis" name="diffexp">
          <component :is="diffexpVue"></component>
        </el-tab-pane>

        <el-tab-pane label="Survival Analysis" name="survival">
          <component :is="survivalVue"></component>
        </el-tab-pane>

        <el-tab-pane label="Signature Analysis" name="signature">
          <component :is="signatureVue"></component>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script>
const wersurvival = resolve => require(["./survival.vue"], resolve);
const werdiffexp = resolve => require(["./expression/home.vue"], resolve);
const wersignature = resolve => require(["./signature.vue"], resolve);

//import { hsv2rgb, gStyle } from "../../../static/js/utils.js";

export default {
  data() {
    return {
      activeName: "diffexp",
      diffexpVue: "",
      survivalVue: "",
      signatureVue: ""
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
        case "survival":
          this.survivalVue = wersurvival;
          break;
        case "signature":
          this.signatureVue = wersignature;
          break;
      }
    }
  }
};
</script>

<style>
div#wertab {
  margin-bottom: 20px;
}

#tab-diffexp,
#tab-survival,
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

@import "./style.css";

</style>
