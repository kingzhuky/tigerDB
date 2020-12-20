<template>
    <div>
    <el-row id="readme">Readme:</el-row>
    <el-card id="readmeCard">
    1. Input genes to analyze the immune signature of pan-cancer species.
    <br />2. Correlation heat map shows the correlation between user-defined genes between pan-cancer species and immune signatures.
    <br />3. Click the correlation heatmap to display the detailed correlation scatter plot.
    </el-card>
    <el-row>
        <el-col push="2" span="10" align="center">
          <el-upload
            class="upload-demo"
            action="/tiger/upload.php"
            name="exptable"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :before-remove="beforeRemove"
            :limit="1"
            :on-exceed="handleExceed"
            :on-success="handleAvatarSuccess">
            <el-button id="immusignatureplot">Upload Expression Matrix</el-button>
          </el-upload>
        </el-col>
        <el-col push="8" span="2">
            <el-button id="immusignatureplot" @click="handleEdit">Example</el-button>
        </el-col>
        
    </el-row>
    <br />
    <el-row>
      <el-col push="2" span="10" align="center">
          <el-upload
            class="upload-demo"
            action="/tiger/upload.php"
            name="exptable"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :before-remove="beforeRemove"
            :limit="1"
            :on-exceed="handleExceed"
            :on-success="handleAvatarSuccess2">
            <el-button id="immusignatureplot">Upload Group Anno File</el-button>
          </el-upload>
        </el-col>
      <el-col push="8" span="2">
        <el-button id="immusignatureplot" @click="submitAnalysis">Submit</el-button>
      </el-col>
    </el-row>
    </br>
    <el-row>
      <v-customdetail
        ref="immuneSigCustomDetail"
        v-show="isShow"
        :expDataPath="expDataPath"
        :annoDataPath="annoDataPath"
        :taskuid="taskuid"
      ></v-customdetail>
    </el-row>
    </div>
</template>


<script>
import {
  scrollCol,
  toTarget,
  gStyle,
  move,
  stop,
} from "../../../static/js/utils.js";
export default {
  data() {
    return {
      isShow: false,
      expDataPath: "",
      annoDataPath: "none",
      taskuid: "",
    };
  },
  created(){

  },

  methods: {
    handleRemove(file, fileList) {
      // console.log(file, fileList);
    },
    handlePreview(file) {
      // console.log(file);
    },
    handleExceed(files, fileList) {
      fileList[0].name = files[0].name
    },
    beforeRemove(file, fileList) {
      return this.$confi
      rm(`确定移除 ${ file.name }？`);
    },
    handleAvatarSuccess(response, file){
      console.log(response.list);
      this.expDataPath = response.list
      this.taskuid = file.uid
    },
    handleAvatarSuccess2(response, file){
      console.log(response.list)
      this.annoDataPath = response.list
    },
    submitAnalysis(){
      console.log("start ~~");
      // this.expDataPath = "Download/customSig_example.exp.tsv.zip";
      // this.annoDataPath = "Download/customSig_example.anno.tsv.zip";
      this.$refs.immuneSigCustomDetail.analysisData(this.expDataPath,this.annoDataPath,this.taskuid)
      this.isShow = true
    },
    handleEdit(){
      window.open("/tiger/Download/customSig_example.anno.tsv.zip")
      window.open("/tiger/Download/customSig_example.exp.tsv.zip")
    }
  },
  components: {
    "v-customdetail": () => import("./immuneSigCustomDetail.vue"),
  },
};
</script>

<style>
#immuneSigTable th {
  left: 35px !important;
  height: 70px !important;
}
#immusignatureplot {
  width: 100%;
  background-color: rgb(20, 146, 140) !important;
  color: white;
  font-weight: bold;
}
</style>