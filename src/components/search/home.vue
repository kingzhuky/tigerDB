<template>
  <div>
    <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
      1.The integration of CRISPR Screen and shRNA Screen shows the correlation between genes and immunity in cell experiments.
      <br />2.Click to get detailed Screen data information and gene-related drug information.
    </el-card>

    <div class="serachpage">
      <el-card class="box-card3" id="searchpart">
        <el-row class="searchrow">
          <el-col :span="8" :offset="6">
            <el-autocomplete
              id="autoInput"
              v-model="seargene"
              style="min-width:100px"
              placeholder="Input Gene Symbol"
              :fetch-suggestions="querySearchAsync"
              @input="selectchange"
            ></el-autocomplete>
          </el-col>
          <el-col :span="4">
            <el-button id="homebt" @click="submsearch" :disabled="isDisable">Search</el-button>
          </el-col>
        </el-row>
      </el-card>

      <br />
    </div>
    <div id="homecard">
      <el-card v-show="homeShow">
        <div>
          <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="werTab">
            <el-tab-pane label="General Information" name="generalInformation">
              <component
                :is="generalInformationVue"
                ref="generalInformationVueRef"
                :seargene="seargene"
              ></component>
            </el-tab-pane>

            <el-tab-pane label="immune Response" name="survival">
              <component  :is="survivalVue" ref="immuResponseVueRef" :seargene="seargene"></component>
            </el-tab-pane>

            <el-tab-pane label="Single-Cell Immunity" name="SingleCellImmunity">
              <component :is="celltypeVue" ref="celltypeVueRef" :seargene="seargene"></component>
            </el-tab-pane>
            <!-- 
            <el-tab-pane label="Differential Expression Analysis" name="diffexp">
              <component :is="diffexpVue"></component>
            </el-tab-pane>-->

            <el-tab-pane label="Signature Analysis" name="signature">
              <component :is="signatureVue"></component>
            </el-tab-pane>
          </el-tabs>
        </div>
      </el-card>
    </div>
  </div>
</template>


<script>
const wercelltype = (resolve) => require(["./SingleCellImmunity.vue"], resolve);
const wersurvival = (resolve) => require(["./immuneResponse.vue"], resolve);
const wersignature = (resolve) => require(["./signature.vue"], resolve);
//const wergeneralInformation = "./generalInformation.vue";

import wergeneralInformation from "./generalInformation.vue";

export default {
  data() {
    return {
      genesug: "m6a2target/genesug",
      homeShow: true,
      isActive: true,
      restaurants: [],
      showSnackbar: false,
      seargene: "A2M",
      activeName: "generalInformation",
      celltypeVue: "",
      diffexpVue: "",
      survivalVue: "",
      signatureVue: "",
      generalInformationVue: "",
    };
  },
  created() {
    this.generalInformationVue = wergeneralInformation;
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      if (to.params.gene !== undefined && to.params.gene.length !== 0) {
        vm.seargene = to.params.gene;
        vm.submsearch();
      }
    });
  },
  mounted() {
    if (this.$route.params.gene !== undefined) {
      this.seargene = this.$route.params.gene;
      this.submsearch();
    }
  },

  methods: {
    handleClick(tab, event) {
      this.checkVue(tab.name);
    },

    checkVue(name) {
      switch (name) {
        case "SingleCellImmunity":
          this.celltypeVue = wercelltype;
          break;
        case "survival":
          this.survivalVue = wersurvival;
          //this.$refs.immuResponseVueRef.plot();
          break;
        case "signature":
          this.signatureVue = wersignature;
          break;
        case "generalInformation":
          this.generalInformationVue = wergeneralInformation;
          break;
      }
    },
    submsearch() {
      if (this.seargene == "") {
        alert("Please input Gene");
      } else {
        this.homeShow = true;
        this.$refs.generalInformationVueRef.getdatagene();
        this.$refs.generalInformationVueRef.tableDetail(this.seargene);
        //toTarget(820);
      }
    },

    selectchange() {
      this.$http
        .get(this.genesug, {
          params: {
            species: "Human",
            gene: this.seargene,
          },
        })
        .then((res) => {
          this.restaurants = res.data.datasetinfo;
        });
    },
    querySearchAsync(queryString, cb) {
      var restaurants = this.restaurants;
      var results = queryString
        ? restaurants.filter(this.createStateFilter(queryString))
        : restaurants;
      cb(results);
    },

    createStateFilter(queryString) {
      return (restaurant) => {
        return (
          restaurant.value.toLowerCase().indexOf(queryString.toLowerCase()) ===
          0
        );
      };
    },
  },
  components: {
    generalInformationVue: wergeneralInformation,
  },
};
</script>

<style>

.textitem {
  padding-bottom: 20px;
}
.card-title {
  text-align: left;
  padding-left: 10px;
  border-left: 5px solid rgb(20, 146, 140);
  color: rgb(20, 146, 140);
  font-size: 1.5em;
  margin-bottom: 15px;
  text-transform: capitalize;
}
#readme {
  color: rgb(20, 146, 140);
  font-weight: bold;
  font-size: 20px;
  padding-bottom: 10px;
}

div#readmeCard {
  font-size: 16px;
  line-height: 22px;
  border-color: rgb(20, 146, 140);
  margin-bottom: 20px;
}
#homebt {
  background-color: rgb(20, 146, 140) !important;
  font-weight: bold;
  color: white !important;
  width: 100%;
}

#seargene {
  width: 105px;
}

#searchpart .el-input {
  position: relative !important;
  font-size: 14px !important;
  /* display: inline-block !important; */
  width: 100% !important;
}

.searchrow {
  padding-top: 25px !important;
}

.tableSearch {
  margin-top: 50px !important;
  border-radius: 15px !important;
}

#noresu {
  text-align: center;
  font-size: 30px;
  color: #f89191;
}

.box-card3 {
  border-radius: 15px !important;
}

#searchpart .demonstration {
  text-align: right !important;
  vertical-align: middle !important;
  float: left !important;
  color: #606266 !important;
  line-height: 40px !important;
  box-sizing: border-box !important;
  width: 100% !important;
  font-size: 22px !important;
  font-weight: bold !important;
}

#serachbt {
  font-size: 24px !important;
  margin-left: 70px !important;
}
</style>