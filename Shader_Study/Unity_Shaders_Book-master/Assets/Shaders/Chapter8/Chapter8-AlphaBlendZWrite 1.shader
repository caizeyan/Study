﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CZY/Alpha Blend ZWrite" {
	Properties {
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_AlphaScale("Alpha Sclae",Range(0,1)) = 1
	}
	SubShader {
		Tags {"Queue" = "Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		Pass{
			ZWrite Off
			ColorMask 0	
		}
		
		Pass {
			Tags{"LightMode"="ForwardBase"}
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _AlphaScale;
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos =  mul(unity_ObjectToWorld,v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed4 texColor =  tex2D(_MainTex,i.uv);
				fixed3 aldobe = texColor*_Color;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT*aldobe;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightDir = WorldSpaceLightDir(i.worldPos);
				fixed3 diffuse = _LightColor0*aldobe*saturate(dot(lightDir,worldNormal));
				return fixed4(ambient+diffuse,texColor.a*_AlphaScale);
			}
			
			ENDCG
		}
	} 
	FallBack "Transparent/VertexLit"
}
