<template>
  <div>
    <el-row>
      <el-col :span="12">
        <img class="iconsCancer" alt="imgurl" :src="imgurl" />
      </el-col>
      <el-col :span="12">
        <p>{{IconName}}</p>
        <el-row class="rowbutton" v-for="dataset in datasets" :key="dataset">
          <el-button type="text" @click="changedataset(dataset)">{{dataset}}</el-button>
        </el-row>
        
      </el-col>
    </el-row>
  </div>
</template>

<script>

export default {
  props: {
    imgurl: String,
    IconName: String,
    datasets: Array,
  },
  data(){
    return{
      // imgurl: require("../../assets/Icons/Bladder.png"),
      // IconName: "Bladder",
    //   datasets: [
    //     {
    //       name: "BCC",
    //       id: "BCC"
    //     },{
    //       name: "BCC",
    //       id: "BCC1"
    //     }],
    }
  },
  methods:{
  changedataset(datasetid){
    console.log(this.imgurl)
    console.log("child: " + datasetid)
    this.$emit("datasetid",datasetid)
  }
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