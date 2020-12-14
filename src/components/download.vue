<template>
  <div class="outside">
    <el-row >
      <el-col :push="1" :span="22">
        <p class="title">Immunotherapy Dataset</p>
      </el-col>
    </el-row>
    <el-row>
      <el-col :push="2" :span="20">
        <el-table :data="validationData" max-height="620" stripe border style="width: 100%">
          <el-table-column property="Study" label="Study" align="center" ></el-table-column>
          <el-table-column property="PMID" label="PMID" align="center" ></el-table-column>
          <el-table-column property="Data" label="Data type" align="center"></el-table-column>
          <el-table-column label="Clinical Data" align="center">
            <template slot-scope="scope">
              <el-button
                type="primary"
                plain
                icon="el-icon-download"
                @click="handleEdit(scope.$index, scope.row.file)"
              >Download</el-button>
            </template>
          </el-table-column>
          <el-table-column label="Expression Data" align="center">
            <template slot-scope="scope">
              <el-button
                type="primary"
                plain
                icon="el-icon-download"
                @click="handleEdit(scope.$index, scope.row.file)"
              >Download</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-col>
    </el-row>
    <el-row>
      <el-col :offset="1" :span="22">
        <el-divider></el-divider>
      </el-col>
      <el-col :offset="1" :span="20">
        <p class="title">Study related to Immune Signature</p>
      </el-col>
    </el-row>
    <el-row>
      <el-col :offset="2" :span="20">
        <el-table :data="validationData" max-height="620" stripe border style="width: 100%">
          <el-table-column property="Species" align="center" label="Species"></el-table-column>
          <el-table-column property="Assembly" align="center" label="Genome Assembly"></el-table-column>
          <el-table-column property="Data" label="Data type" align="center"></el-table-column>
          <el-table-column label="File" align="center">
            <template slot-scope="scope">
              <el-button
                type="primary"
                plain
                icon="el-icon-download"
                @click="handleEdit(scope.$index, scope.row.file)"
              >Download</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-col>
    </el-row>
    <el-row>
      <el-col :offset="1" :span="22">
        <el-divider></el-divider>
      </el-col>
      <el-col :offset="1" :span="20">
        <p class="title">Cell Type Marker List</p>
      </el-col>
    </el-row>
    <el-row>
      <el-col :offset="2" :span="20">
        <el-table :data="validationData" max-height="620" stripe border style="width: 100%">
          <el-table-column property="Species" align="center" label="Species"></el-table-column>
          <el-table-column property="Assembly" align="center" label="Genome Assembly"></el-table-column>
          <el-table-column property="Data" label="Data type" align="center"></el-table-column>
          <el-table-column label="File" align="center">
            <template slot-scope="scope">
              <el-button
                type="primary"
                plain
                icon="el-icon-download"
                @click="handleEdit(scope.$index, scope.row.file)"
              >Download</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-col>
    </el-row>
    <el-row>
      <el-col :offset="1" :span="22">
        <el-divider></el-divider>
      </el-col>
      <el-col :offset="1" :span="20">
        <p class="title">Immune Screening Dataset</p>
      </el-col>
    </el-row>
    <el-row>
      <el-col :offset="2" :span="20">
        <el-table :data="validationData" max-height="620" stripe border style="width: 100%">
          <el-table-column property="Species" align="center" label="Species"></el-table-column>
          <el-table-column property="Assembly" align="center" label="Genome Assembly"></el-table-column>
          <el-table-column property="Data" label="Data type" align="center"></el-table-column>
          <el-table-column label="File" align="center">
            <template slot-scope="scope">
              <el-button
                type="primary"
                plain
                icon="el-icon-download"
                @click="handleEdit(scope.$index, scope.row.file)"
              >Download</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-col>
    </el-row>
    <el-row>
      <el-col :offset="1" :span="22">
        <el-divider></el-divider>
      </el-col>
      <el-col :offset="1" :span="20">
        <p class="title">Analysis Result</p>
      </el-col>
    </el-row>
    <el-row>
      <el-col :offset="2" :span="20">
        <el-table :data="validationData" max-height="620" stripe border style="width: 100%">
          <el-table-column property="Species" align="center" label="Species"></el-table-column>
          <el-table-column property="Assembly" align="center" label="Genome Assembly"></el-table-column>
          <el-table-column property="Data" label="Data type" align="center"></el-table-column>
          <el-table-column label="File" align="center">
            <template slot-scope="scope">
              <el-button
                type="primary"
                plain
                icon="el-icon-download"
                @click="handleEdit(scope.$index, scope.row.file)"
              >Download</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-col>
    </el-row>
  </div>
</template>


<script>
export default {
  data() {
    return {
      validationData: [
        {
          id: "1",
          Species: "Human",
          Assembly: "hg38",
          Data: "Validated Target",
          file: "validation_human_download.zip",
        },
        {
          id: "2",
          Species: "Human",
          Assembly: "hg38",
          Data: "Potential Target (Binding)",
          file: "binding_human_download.zip",
        },
        {
          id: "3",
          Species: "Human",
          Assembly: "hg38",
          Data: "Potential Target (Perturbation)",
          file: "perturbated_human_download.zip",
        },
        {
          id: "4",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Validated Target",
          file: "validation_human_download.zip",
        },
        {
          id: "5",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Potential Target (Binding)",
          file: "",
        },
        {
          id: "6",
          Species: "Mouse",
          Assembly: "mm10",
          Data: "Potential Target (Perturbation)",
          file: "perturbated_mouse_download.zip",
        },
      ],
    };
  },
  created(){
    console.log(this.validationData)
  },
  methods: {
    handleEdit(index, file) {
      console.log(index)
      window.open("/igvurl/m6a2target/downloadfile/" + file);
    },
  },
  components: {},
};
</script>

<style>
.title {
  color: rgb(20, 146, 140);
  font-size: 30px;
}
.el-row {
  margin-top: 30px;
  margin-bottom: 20px;
}
.el-col {
  border-radius: 20px;
}
</style>
