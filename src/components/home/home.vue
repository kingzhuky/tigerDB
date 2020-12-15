<template>
  <div class="outside">
    <div class="section">
      <el-row>
        <el-col :span="20" :offset="2">
          <el-row id="homeinbt">
              <p class="hometitle" style="text-align:center;">Welcome to TIGER</p>
              <p class="homesubtitle" style="text-align:center;">A Web Portal of Tumor Immunotherapy Gene Expression Resource</p>
            <el-col :span="8" :offset="6" id="homeInput">
              <el-autocomplete
                v-model="seargene"
                placeholder="Please Input A Gene Symbol (e.g. PDCD1 or CXCL13)"
                :fetch-suggestions="querySearchAsync"
                @keyup.enter.native="submsearch"
              ></el-autocomplete>
            </el-col>
            <el-col :span="4">
              <el-button id="homebt" @click="submsearch">Search</el-button>
            </el-col>
          </el-row>
          <!-- <el-row class="homedesrc" style="text-align:center;margin: 10px 0 -10px 0 ">
            <el-col :span="8" :offset="6">Example: PDCD1, CXCL13</el-col>
          </el-row> -->
          <el-row>
            <p class="homedesrc">
              TIGER is a web-accessible portal for integrative analysis of the gene expression data related to tumor immunology. TIGER contains bulk transcriptome data for xxx tumor samples with immunotherapy clinical outcome and xxx tumor/normal samples from TCGA, and single cell transcriptome data for xxx immune cells of xxx samples, among which xxx immune cells of xxx samples have immunotherapy clinical data. 
            </p>
          </el-row>
        </el-col>
        <el-col :offset="1">
          <el-row>
            <p class="homesubtitle">
              TIGER provides the following four modules to access the resource
            </p>
          </el-row>
          <el-row>
            <el-col :span="5">
              <el-card class="box-card" @click.native="openpage('immuneResponse')">
                <div slot="header" class="clearfix" style="text-align:center;">
                  <span class="homedesrc">Immune Response</span>
                  <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
                </div>
                <div style="text-align:center;">
                  <img src="../../assets/logo.png" />
                </div>
              </el-card>
            </el-col>
            <el-col :span="5" >
              <el-card class="box-card" style="position:relative;left:30px;" @click.native="openpage('immuneSignature')">
                <div slot="header" class="clearfix" style="text-align:center;">
                  <span class="homedesrc">Immune Signature</span>
                  <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
                </div>
                <div style="text-align:center;">
                  <img src="../../assets/logo.png" />
                </div>
              </el-card>
            </el-col>
            <el-col :span="5">
              <el-card class="box-card" style="position:relative;left:60px;" @click.native="openpage('singleCellImmune')">
                <div slot="header" class="clearfix" style="text-align:center;">
                  <span class="homedesrc">Single Cell Immunity</span>
                  <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
                </div>
                <div style="text-align:center;">
                  <img src="../../assets/logo.png" />
                </div>
              </el-card>
            </el-col>
            <el-col :span="5">
              <el-card class="box-card" style="position:relative;left:90px;" @click.native="openpage('immuneScreen')">
                <div slot="header" class="clearfix" style="text-align:center;">
                  <span class="homedesrc">Immune Screening</span>
                  <!-- <el-button style="float: right; padding: 3px 0" type="text">操作按钮</el-button> -->
                </div>
                <div style="text-align:center;">
                  <img src="../../assets/logo.png" />
                </div>
              </el-card>
            </el-col>
          </el-row>
        </el-col>
        <!-- <el-col :span="9" :offset="1">
          <div id="homepic">
            <img src="../../assets/home1.png" />
            <el-row>
              <el-col :span="12">
                <p class="hometitle">Quick Search</p>
              </el-col>
            </el-row>
            <el-col :span="14" id="homeInput">
              <el-autocomplete
                v-model="seargene"
                placeholder="Please Input Gene Symbol"
                :fetch-suggestions="querySearchAsync"
                @keyup.enter.native="submsearch"
              ></el-autocomplete>
            </el-col>
            <el-col :span="6">
              <el-button id="homebt" @click="submsearch">Search</el-button>
            </el-col>
          </div>
        </el-col> -->
      </el-row>
    </div>
  </div>
</template>

<script>
//import { toTarget } from "../../../static/js/utils.js";

export default {
  name: "home",
  data: function () {
    return {
      seargene: "",
      restaurants: [],
    };
  },

  methods: {
    openpage(pagename){
      this.$router.push({
        name: pagename,
      });
    },
    querySearchAsync(queryString, cb) {
      this.$http
        .get("/m6a2target/genesug", {
          params: {
            gene: this.seargene,
            species: "Human",
          },
        })
        .then((res) => {
          cb(res.data.datasetinfo);
        });
    },

    createStateFilter(queryString) {
      return (restaurant) => {
        return (
          restaurant.value.toLowerCase().indexOf(queryString.toLowerCase()) ===
          0
        );
      };
    },

    submsearch() {
      console.log(this.seargene);
      if (this.seargene.trim() === "") {
        alert("Please input Gene");
      } else {
        this.$router.push({
          name: "search",
          params: {
            gene: this.seargene,
          },
        });
      }
    },
  },
};
</script>

<style>
.time {
  font-size: 13px;
  color: #999;
}
#homeInput .el-autocomplete {
  width: 100%;
}
#homebt {
  background-color: rgb(20, 141, 135) !important;
  font-weight: bold;
  color: white !important;
  width: 100%;
}
#homeinbt .el-autocomplete {
  width: 100% !important;
}
.box-card {
  width: auto;
  /* margin-left: 100px; */
  /* margin: auto; */
}
.homeboxrow {
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
}

.hometitle {
  color: rgb(20, 146, 140) !important;
  font-size: 30px;
  font-weight: bolder;
}
.homesubtitle {
  color: rgb(0, 0, 0) !important;
  font-size: 24px;
  font-weight: bolder;
}
.homedesrc {
  font-size: 20px;
  line-height: 28px;
}
.quickSearch {
  font-size: 20px;
  font-weight: 500px;
}
div#homepic {
  padding-top: 85px;
}
div#homecard {
  padding: 10px;
}
</style>