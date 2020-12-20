<template>
  <transition name="move3">
    <div>
      <el-card id="scummuviewer">
        <p class="card-title">Cross Talk</p>
        <el-row>
          <el-col :span="7" :offset="3">
            <el-row>
              <span id="homespan">Select Cluster</span>
            </el-row>
          </el-col>
          <el-col :span="7">
            <el-row>
              <span id="homespan">Select Cell Type</span>
            </el-row>
          </el-col>
          <!-- <el-col :span="10">
            <el-row>
              <span id="homespan">Search Ligand or Receptor</span>
            </el-row>
          </el-col> -->
        </el-row>
        <br />
        <el-row>
          <el-col :span="7" :offset="3">
            <el-select v-model="gloclu" placeholder="Select Cluster" @change="GlobalClusterChange">
              <el-option
                v-for="item in gloCluoptions"
                :key="item.GlobalCluster"
                :label="item.GlobalCluster"
                :value="item.GlobalCluster"
              ></el-option>
            </el-select>
          </el-col>

          <el-col :span="7" :offset="0">
            <el-select
              v-model="crossClu"
              placeholder="Select CellType"
              v-loading="crossCluloading"
            >
            <el-option 
              v-for="item in crossClucoptions" 
              :key="item.CellType" 
              :label="item.CellType" 
              :value="item.CellType"
            ></el-option>
            </el-select>
          </el-col>
          <el-col :span="2" :offset="1">
            <el-button id="scimmubt" @click="searchCro">Search</el-button>
          </el-col>
        </el-row>

        <div id="crossplot" v-loading="crossloading" v-show="scimmuShow">
          <!-- <el-row class="detailimg" v-if="crossplots.split(',').length>1">
            <el-col :span="8">
              <img id="singleimg2" :src="'tiger/img/'+crossplots.split(',')[0]+'.png'" />
            </el-col>
            <el-col :span="8">
              <img id="singleimg2" :src="'tiger/img/'+crossplots.split(',')[1]+'.png'" />
            </el-col>
            <el-col :span="8">
              <img id="singleimg2" :src="'tiger/img/'+crossplots.split(',')[2]+'.png'" />
            </el-col>
          </el-row> -->
          <el-card>
            <el-table
              class="tigtablele"
              id="immuneSigTable"
              ref="singleTable"
              border
              max-height="800"
              :data="tableData"
              @cell-click="heandleclick"
              :cell-style="tableCellStyle"
              style="100%"
            >
              <el-table-column
                v-for="(item,index) in tableDataheader"
                :key="index"
                :property="item"
                :label="item"
                sortable
                align="center"
                width="80"
              >
                <template
                  slot-scope="scope"
                >{{ scope.row[item]===undefined ? '': scope.row[item].split('_')[0] }}</template>
              </el-table-column>
              <el-table-column property=" " label=" " align="center" width="120"></el-table-column>
            </el-table>

            <div class="colorbar">
              <span>Negative correlation</span>
              <span class="heatMapTable--colorbar"></span>
              <span>Positive correlation</span>
            </div>
            <div id="logFC">correlation</div>
          </el-card>
        </div>
        <div v-show="scimmuShowNoRes" id="norult">No result</div>
      </el-card>
      <v-goTop></v-goTop>
    </div>
  </transition>
</template>

<script>
import goTop from "../public/goTop";

export default {
  props: {
    gene: {
      type: String,
    },
    cancer: {
      type: String,
    },
    clickGene: {
      type: String,
    },
    gloCluoptions: Array,
  },

  data() {
    return {
      gloclu: this.gloCluoptions[0].GlobalCluster,
      crossCluloading: true,
      crossloading: false,
      plots: "",
      crossplots: "",
      seargene: "HLA-A_CD3G",
      restaurants: [],
      crossClucoptions: [],
      crossClu: [],
      scimmuShowNoRes: false,
      tableData: [],
      tableDataheader: [],
    };
  },

  mounted() {
    this.getCellType();
  },

  methods: {
    checkInput() {
      if (this.normalMed !== "None" && this.normalGene.length == 0) {
        alert("please input Normalized gene or Cell fration");
        return false;
      }
      return true;
    },
    clickPlot() {
      this.genePlot(this.clickGene);
    },
    getCellType() {
      this.crossCluloading = true;
      this.$http
        .get("/tiger/scCelltype.php", {
          params: {
            CancerType: this.cancer,
            GlobalCluster: this.gloclu,
          },
        })
        .then((res) => {
          if (res.data.status === 200) {
            this.crossClucoptions = res.data.list;
            this.crossClu = [res.data.list[0].CellType];
            this.crossCluloading = false;
          }
        });
    },
    GlobalClusterChange() {
      this.getCellType();
    },

    checkdataset() {
      if (
        (Array.isArray(this.crossClu) && this.crossClu.length === 0) 
      ) {
        return true;
      }
      return false;
    },

    reset() {
      this.scimmuShow = false;
      this.scimmuShowNoRes = false;
    },

    searchCro() {
      if (!this.checkdataset()) {
        this.scimmuShow = true;
        this.scimmuShowNoRes = false;
        this.crossloading = true;
        var that = this;

        this.$http
          .get("/tiger/singlecellcrosstable.php", {
            params: {
              celltype: that.crossClu.join(","),
              sqltable: "sccrosstalk_" + that.cancer,
            },
          })
          .then(function (res) {
            // if (res.data.status == 0) {
              // setTimeout((that.crossplots = res.data.output[0]), 1000);
              that.tableData = res.data.list
              that.tableDataheader = Object.keys(res.data.list[0])
              console.log(that.tableData)
            // } else {
              that.scimmuShow = false;
              that.scimmuShowNoRes = true;
            // }
            that.crossloading = false;
          })
          .catch(function (res) {
            console.log(res);
          });
      } else {
        alert("Please  select cross Clusters");
      }
    },
  },

  components: {
    "v-goTop": goTop,
  },
};
</script>

<style>
.singleimg2 {
  width: 400px;
}
</style>


