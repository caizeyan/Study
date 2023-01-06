// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CZY/Mask Texture" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularMask ("Specular Mask", 2D) = "white" {}
		_SpecularScale ("Specular Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			float4 _Specular;
			float _Gloss;
			sampler2D _SpecularMask;
			float4 _SpecularMask_ST;
			float _SpecularScale;
			
			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};
			
			struct v2f {
				float4 pos:SV_POSITION;
				float3 lightDir:TEXCOORD0;
				float3 viewDir:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
			 	fixed3 tangentView = normalize(i.viewDir);
				fixed3 tangentLight = normalize(i.lightDir);
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uv));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0-saturate( dot(tangentNormal.xy,tangentNormal.xy)));

				fixed3 albedo = _Color.rgb*tex2D(_MainTex,i.uv).rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT*albedo;

				fixed3 diffuse = _LightColor0*albedo*max(0,dot(tangentLight,tangentNormal));

				fixed3 halfDir = normalize(tangentView+tangentLight);
				float specularScale = tex2D(_SpecularMask,i.uv).r*_SpecularScale;
				fixed3 specular = _LightColor0*_Specular*pow(max(0,dot(tangentNormal,halfDir)),_Gloss)*specularScale;
				return fixed4(ambient+diffuse+specular, 1.0);


			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
