// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CZY/Single Texture" {
	Properties{
		_Color("Tint Color",Color) = (1,1,1,1)
		_MainTex("MainTex",2D) = "white" {}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Glose",Range(8.0,256)) = 20	
	}
	SubShader{
		Pass{
			Tags{"LightModel" = "ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord :TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 adobe = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * adobe;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightDir = normalize( UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = _LightColor0.rgb*adobe*max(0,dot(worldNormal,lightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize((lightDir+viewDir));
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow( max(0,dot(halfDir,worldNormal)),_Gloss);

				fixed3 color = ambient+diffuse+specular;
				return fixed4(color,1);
			}
			
			ENDCG
		}	
	}
	FallBack "Specular"
}
