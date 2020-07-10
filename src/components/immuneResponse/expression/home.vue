<template>
  <div>
    <div id="expressioTab">
      <el-card class="expressionCard">
        <el-tabs v-model="weractiveName"  @tab-click="handleClick2"  >
          <el-tab-pane label="Response VS Non-Response" name="response" >
            <component :is="responseVue"></component>
          </el-tab-pane>

          <el-tab-pane label="Pre-Therapy VS Post-Therapy" name="therapy">
            <component :is="therapyVue"></component>
          </el-tab-pane>
        </el-tabs>
      </el-card>
    </div>
  </div>

</template>

<script>

const response = resolve => require(["./responseVS.vue"], resolve);
const therapy = resolve => require(["./therapyVS.vue"], resolve);

export default {
  data() {
    return {
      weractiveName: "response",
      therapy: "",
    };
  },
  created() {
    this.responseVue = response;
    this.therapyVue='';
  },

  methods: {
     handleClick2(tab, event) {
      this.checkVue(tab.name);
    },
    checkVue(name) {
      switch (name) {
        case "response":
          this.responseVue = response;
          break;
        case "therapy":
          this.therapyVue = therapy;
          break;
      }
    }
  }
  
};

</script>


<style>

#tab-response,#tab-therapy {
  font-size: 18px;
  height: 40px;
  padding: 0px 10px;
  font-weight: bold !important;
}

</style>



