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
      <el-card class="tableSearch" v-show="ValidatedTable">result</el-card>
    </div>
    <div id="homecard">
      <el-card v-show="homeShow">
        <div>
          <el-tabs v-model="activeName" type="card" @tab-click="handleClick" stretch class="werTab">

            <el-tab-pane label="General Information" name="generalInformation">
              <component :is="generalInformationVue" ref="generalInformationVueRef" :seargene="seargene"></component>
            </el-tab-pane>


            <el-tab-pane label="Single-Cell Immunity" name="celltype">
              <component :is="celltypeVue" ref="celltypeVueRef" :seargene="seargene"></component>
            </el-tab-pane>
<!-- 
            <el-tab-pane label="Differential Expression Analysis" name="diffexp">
              <component :is="diffexpVue"></component>
            </el-tab-pane> -->

            <el-tab-pane label="Survival Analysis" name="survival">
              <component :is="survivalVue"></component>
            </el-tab-pane>

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
const wercelltype = (resolve) => require(["./celltype.vue"], resolve);
const wersurvival = (resolve) => require(["./survival.vue"], resolve);
const wersignature = (resolve) => require(["./signature.vue"], resolve);
const wergeneralInformation = (resolve) => require(["./generalInformation.vue"], resolve);



export default {
  data() {
    return {
      homeShow: false,
      isActive: true,
      restaurants: [],
      showSnackbar: false,
      seargene: "PDCD1",
      activeName: "celltype",
      celltypeVue: "",
      diffexpVue: "",
      survivalVue: "",
      signatureVue: "",
      generalInformationVue: "",
    };
  },
  created() {
    this.celltypeVue = wercelltype;
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
    this.celllineoptions = this.humanoptions;
    this.typeweroptions = this.hgweroptions;
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
        case "celltype":
          this.celltypeVue = wercelltype;
          break;
        case "survival":
          this.survivalVue = wersurvival;
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
        this.$refs.celltypeVueRef.getTableData();
        //toTarget(820);
      }
    },

    selectchange() {
      this.$http
        .get(this.genesug, {
          params: {
            species: 'Human',
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
  components: {},
};
</script>

<style>
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