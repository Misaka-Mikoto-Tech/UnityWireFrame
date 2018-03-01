// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/TestShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Width("WireWidth", Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 300

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma enable_d3d11_debug_symbols
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float  _WireWidth;

			v2f vert (appdata v)
			{
				v2f o = (v2f)0;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma enable_d3d11_debug_symbols

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
				uint vid : SV_VertexID;
			};

			struct v2f
			{
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				half3 barycentric : TEXCOORD2;
				half3 worldNormal : TEXCOORD3;
				half3 viewDir : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float  _WireWidth;

			v2f vert (appdata v)
			{
				const half3x3 _barycentrics = half3x3(half3(0, 1, 0), half3(1, 0, 0), half3(0, 0, 1));

				v2f o = (v2f)0;
				o.vertex = mul(UNITY_MATRIX_M, v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldNormal = normalize(o.worldNormal);
				o.vertex.xyz += o.worldNormal * 0.0005;

				o.vertex = mul(UNITY_MATRIX_VP, o.vertex);
				o.barycentric = _barycentrics[v.vid % 3];

				o.viewDir=normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 d = fwidth(i.barycentric);
				fixed3 a3 = smoothstep(fixed3(0,0,0), d * _WireWidth, i.barycentric);
				float min_dist = 1.0 - min(min(a3.x, a3.y), a3.z);

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldViewDir = normalize(i.viewDir);
				fixed dir = dot(worldNormal, worldViewDir);
				if(dir <= 0.001)
				{
					min_dist = 1.0 - min_dist;
				}

				fixed4 col = min_dist * fixed4(1, 0, 0, min_dist);
				
				return col;
			}
			ENDCG
		}
	}
}
