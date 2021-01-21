<template>
  <div>
    <el-row>
      <el-col :span="12">
        <img class="iconsCancer" alt="imgurl" v-lazy="imgurl" />
      </el-col>
      <el-col :span="12">
        <p>{{IconName}}</p>
        <el-row class="rowbutton" v-for="dataset in datasets" :key="dataset.id">
          <li @click="changedataset(dataset.id)">{{dataset.name}}</li>
        </el-row>
        
      </el-col>
    </el-row>
  </div>
</template>

<script>

export default {
  components: {

  },
  data(){
    return{
      imgurl: require("../../assets/Icons/Bladder.png"),
      IconName: "Bladder",
      datasets: [
        {
          name: "BCC",
          id: "BCC1"
        },{
          name: "BCC",
          id: "BCC1"
        }],
    }
  },
  changedataset(datasetid){
    this.datasetid = datasetid
  }
}
</script>

<style>
.iconsCancer{
  width:80px;
  height:80px;
}
.rowbutton{
  margin-top: -20px;
}
</style>