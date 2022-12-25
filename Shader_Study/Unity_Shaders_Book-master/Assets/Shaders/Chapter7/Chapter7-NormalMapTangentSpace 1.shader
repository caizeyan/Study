// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CZY/Normal Map In Tangent Space" {
	Properties{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("MainTex",2D) = "white"{}
		_BumpMap("Normal Map",2D) = "bump"{}	
		_BumpScale("Normal Scale",float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,255)) = 20
		}
	SubShader{
		Pass{
			Tags {"LightModel" = "ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			sampler2D _BumpMap;
			fixed4 _BumpMap_ST;
			float _BumpScale;
			float _Gloss;
			fixed4 _Specular;
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 lightDir:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
				float4 uv:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy*_BumpMap_ST.xy + _BumpMap_ST.zw;
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex));
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				//UnpackNormal = (packedNormal.xy*2 - 1)
				//tangentNormal.xy = (packedNormal.xy*2 - 1)*_BumpScale;
				//tangentNormal.z = sqrt(1 - dot(tangentNormal.xy,tangentNormal.xy));
				
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
			
				fixed3 adobe = tex2D(_MainTex,i.uv.xy)*_Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * adobe;

				fixed3 diffuse = _LightColor0*adobe*saturate(dot(tangentNormal,tangentLightDir));

				fixed3 halfView = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0*_Specular*pow(max(0,dot(halfView,tangentNormal)),_Gloss);
				
				return fixed4(ambient+diffuse+specular,1);
			}
			ENDCG
		}	
	}
	FallBack "Specular"
}
