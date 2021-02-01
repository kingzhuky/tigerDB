<template>
  <div class="detail-card">
    <el-card id="scummuviewer" class="infor">
    <p class="card-title">Upload Matrix</p>
    <el-row>
    </el-row>
    <br />
    <el-row>
        <el-col span="6" push="2" align="center">
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
              <el-button id="immusignatureplot">Upload Expression Matrix  
                <el-tooltip class="item" effect="light" trigger='hover' content="A RPKM matrix of Bluk RNA-Seq with tab separated" placement="top-start">
                    <i class="el-icon-info"></i>
                  </el-tooltip>
                </el-button>
          </el-upload>
        </el-col>
        <el-col span="6" push="2" align="center">
            <p class=downloadtext >
              <a id="download" href="/tiger/Download/customSig_example.exp.tsv.zip">Download</a>
              the example expression matrix.</p>
        </el-col>
    </el-row>
    <br/>
    <el-row>
        <el-col span="6" push="2">
            <div class="tiggeneinfo">
              <div id="collapseCard">
                <el-collapse>
                  <el-collapse-item title="Optional" name="1">
                    <template slot="title">
                      Optional
                      <i class="el-icon-setting"></i>
                    </template>
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
                      <el-button id="immusignatureplot">Upload Group Anno Table  
                        <el-tooltip class="item" effect="light" trigger='hover' content="Tab-delimited table consisting of two columns (sample_id group)" placement="top-start">
                            <i class="el-icon-info"></i>
                          </el-tooltip>
                        </el-button>
                  </el-upload>
                  <p class=downloadtext>
                    <a id="download" href="/tiger/Download/customSig_example.exp.tsv.zip">Download</a>
                    the example anno table.</p>
                  </el-collapse-item>
                </el-collapse>
              </div>
            </div>
        </el-col>
        <br/>
       <el-col push="12" span="3">
        <el-button id="immusignatureplot" @click="submitAnalysis">Submit</el-button>
      </el-col>
    </el-row>
    </el-card>
    <br />
    <el-card class="infor" v-show="isShow">
      <v-customdetail
        ref="immuneSigCustomDetail"
        v-show="isShow"
        :expDataPath="expDataPath"
        :annoDataPath="annoDataPath"
        :taskuid="taskuid"
      ></v-customdetail>
    </el-card>

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
      // console.log(response.list);
      this.expDataPath = response.list
      this.taskuid = file.uid
    },
    handleAvatarSuccess2(response, file){
      // console.log(response.list)
      this.annoDataPath = response.list
    },
    submitAnalysis(){
      // console.log("start ~~");
      this.expDataPath = this.expDataPath == "" ? "Download/customSig_example.exp.tsv.zip" : this.expDataPath
      // this.annoDataPath = this.annoDataPath == "none" ? "Download/customSig_example.anno.tsv" : this.annoDataPath
      // this.expDataPath = "Download/customSig_example.exp.tsv.zip";
      // this.annoDataPath = "Download/customSig_example.anno.tsv.zip";
      this.$refs.immuneSigCustomDetail.analysisData(this.expDataPath,this.annoDataPath,this.taskuid)
      this.isShow = true
    },
    handleEdit(){
      window.open("/tiger/Download/customSig_example.exp.tsv.zip")
      window.open("/tiger/Download/customSig_example.anno.tsv.zip")
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
.item{
  font-size: 12px;
  font-weight: bold;
}
</style>