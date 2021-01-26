<template>
  <div>
    <el-card shadow="hover" class="cancercard">
      <el-row gutter="10">
        <el-col :span="7">
          <img class="iconsCancer" style="position:relative;top:40px;left:10px" alt="imgurl" :src="imgurl" />
        </el-col>
        <el-col :span="15">
          <p class="cancertitle">{{IconName}}</p>
          <el-row class="rowbutton" v-for="(dataset, index) in datasets" :key="dataset">
            <el-button size="medium" type="text" @click="changedataset(dataset)" :disabled="dataisrenew(dataset)">{{datasetsname[index]}}</el-button>
            <!-- <p @click="changedataset(dataset)" :disabled="dataisrenew(dataset)">{{datasetsname[index]}}</p> -->
          </el-row>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script>
import toTarget from "../public/goTop";
export default {
  props: {
    imgurl: String,
    IconName: String,
    datasets: Array,
    datasetsname: Array,
  },
  data(){
    return{
       datasetrenewed: ["CAC","BC","BCC","MPAL","CRC1","BTCC","UM","CRC2","UCEC","BC1","NSCLC","OV","MCC","HCC","PDAC","NSCLC6","NSCLC1","NSCLC3","CCRCC","TNBC","ICC","NSCLC4","HNSC","NPC","MUC","PRAD2","STAD","PRAD1"],
    }
  },
  methods:{
    changedataset(datasetid){
      // console.log(this.imgurl)
      // console.log("child: " + datasetid)
      this.$emit("datasetid",datasetid)
    },
    dataisrenew(datasetid){
      // console.log(datasetid)
      for(const reneweddata of this.datasetrenewed){
        // console.log(reneweddata)
        if(datasetid === reneweddata){
          return false
        }
      }
      return true
    },
  }

}
</script>

<style>
.el-card {
  margin-bottom: 20px;
}
.cancercard{
  height: 220px;
}
.iconsCancer{
  width: 90px;
  height: 90px;
}
.rowbutton{
  margin-top: -15px;
  font: 22px;
}
.cancertitle {
  text-align: left;
  padding-left: 0px;
  color: rgb(20, 146, 140);
  font-size: 1.1em;
  margin-bottom: 15px;
  text-transform: capitalize;
}
</style>