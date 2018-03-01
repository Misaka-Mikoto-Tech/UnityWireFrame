using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshModifier : MonoBehaviour {

    public SkinnedMeshRenderer smr;
    [Range(1, 3)]
    public float wireWidth = 1.0f;

    private Material _mat;
    void Start () {

        _mat = smr.materials[0];

        Mesh newMesh = ConvertMeshToNoShareFormat(smr.sharedMesh);
        smr.sharedMesh = newMesh;
	}

    /// <summary>
    /// 生成一个索引顺序排列不共享顶点的 Mesh, 体积会增大为原有的 triangles / vertices 倍
    /// </summary>
    /// <param name="mesh"></param>
    /// <returns></returns>
    private Mesh ConvertMeshToNoShareFormat(Mesh mesh)
    {
        Mesh newMesh = new Mesh();

        Vector3[] vertices = mesh.vertices;
        BoneWeight[] boneWeights = mesh.boneWeights;
        int[] triangles = mesh.triangles;
        int triCount = triangles.Length;

        Vector3[] newVertices = new Vector3[triCount];
        BoneWeight[] newBoneWeights = new BoneWeight[triCount];
        for (int i = 0, imax = triCount; i < imax; i++)
        {
            newVertices[i] = vertices[triangles[i]];
            newBoneWeights[i] = boneWeights[triangles[i]];
        }
        newMesh.vertices = newVertices;
        newMesh.boneWeights = newBoneWeights;

        Matrix4x4[] bindposes = mesh.bindposes;
        Matrix4x4[] newBindposes = new Matrix4x4[bindposes.Length];
        System.Array.Copy(bindposes, newBindposes, bindposes.Length);
        newMesh.bindposes = newBindposes;

        if (mesh.normals != null && mesh.normals.Length > 0)
        {
            Vector3[] normals = mesh.normals;
            Vector3[] newNormals = new Vector3[triCount];
            for(int i = 0, imax = triCount; i < imax; i++)
            {
                newNormals[i] = normals[triangles[i]];
            }
            newMesh.normals = newNormals;
        }

        if(mesh.tangents != null && mesh.tangents.Length > 0)
        {
            Vector4[] tangents = mesh.tangents;
            Vector4[] newTangents = new Vector4[triCount];
            for(int i = 0, imax = triCount; i < imax; i++)
            {
                newTangents[i] = tangents[triangles[i]];
            }
            newMesh.tangents = newTangents;
        }

        // TODO 如何处理 Vector3/Vector4 格式的 uv
        if(mesh.uv != null && mesh.uv.Length > 0)
        {
            Vector2[] uv = mesh.uv;
            Vector2[] newUv = new Vector2[triCount];
            for(int i= 0, imax = triCount; i < imax; i++)
            {
                newUv[i] = uv[triangles[i]];
            }
            newMesh.uv = newUv;
        }

        if (mesh.uv2 != null && mesh.uv2.Length > 0)
        {
            Vector2[] uv2 = mesh.uv2;
            Vector2[] newUv2 = new Vector2[triCount];
            for (int i = 0, imax = triCount; i < imax; i++)
            {
                newUv2[i] = uv2[triangles[i]];
            }
            newMesh.uv2 = newUv2;
        }

        if (mesh.uv3 != null && mesh.uv3.Length > 0)
        {
            Vector2[] uv3 = mesh.uv3;
            Vector2[] newUv3 = new Vector2[triCount];
            for (int i = 0, imax = triCount; i < imax; i++)
            {
                newUv3[i] = uv3[triangles[i]];
            }
            newMesh.uv3 = newUv3;
        }

        if (mesh.uv4 != null && mesh.uv4.Length > 0)
        {
            Vector2[] uv4 = mesh.uv4;
            Vector2[] newUv4 = new Vector2[triCount];
            for (int i = 0, imax = triCount; i < imax; i++)
            {
                newUv4[i] = uv4[triangles[i]];
            }
            newMesh.uv4 = newUv4;
        }

        if(mesh.colors != null && mesh.colors.Length > 0)
        {
            Color[] colors = mesh.colors;
            Color[] newColors = new Color[triCount];
            for (int i = 0, imax = triCount; i < imax; i++)
            {
                newColors[i] = colors[triangles[i]];
            }
            newMesh.colors = newColors;
        }

        if(mesh.colors32 != null && mesh.colors32.Length > 0)
        {
            Color32[] colors32 = mesh.colors32;
            Color32[] newColors32 = new Color32[triCount];
            for (int i = 0, imax = triCount; i < imax; i++)
            {
                newColors32[i] = colors32[triangles[i]];
            }
            newMesh.colors32 = newColors32;
        }

        newMesh.subMeshCount = mesh.subMeshCount;
        int idxOffset = 0;
        for (int i= 0, imax = mesh.subMeshCount; i < imax; i++)
        {
            uint subIdxCount = mesh.GetIndexCount(i);
            int[] subIndices = new int[subIdxCount];
            for(int j = 0; j < subIdxCount; j++)
            {
                subIndices[j] = idxOffset + j;
            }

            newMesh.SetIndices(subIndices, MeshTopology.Triangles, i);
            idxOffset += (int)subIdxCount;
        }

        newMesh.bounds = mesh.bounds;
        newMesh.indexFormat = mesh.indexFormat;

        return newMesh;
    }
	
	// Update is called once per frame
	void Update () {
        _mat.SetFloat("_WireWidth", wireWidth);
	}
}
