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
		LOD 100

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
				uint vid : SV_VertexID;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 uv2 : TEXCOORD1;
				half3 barycentric : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float  _WireWidth;

			v2f vert (appdata v)
			{
				const half3x3 _barycentrics = half3x3(half3(1, 0, 0), half3(0, 1, 0), half3(0, 0, 1));

				v2f o = (v2f)0;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.barycentric = _barycentrics[v.vid % 3];
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 d = fwidth(i.barycentric);
				fixed3 a3 = smoothstep(fixed3(0,0,0), d * _WireWidth, i.barycentric);
				float min_dist = 1.0 - min(min(a3.x, a3.y), a3.z);

				fixed4 col = tex2D(_MainTex, i.uv);
				col = min_dist * float4(1,0,0,1) + (1 - min_dist) * col;
				return col;
			}
			ENDCG
		}
	}
}
