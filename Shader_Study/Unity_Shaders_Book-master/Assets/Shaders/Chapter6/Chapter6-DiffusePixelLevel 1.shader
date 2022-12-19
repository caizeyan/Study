// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CZY/Diffuse Pixel-Level" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Diffuse;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
			    v2f o;
			    o.pos = UnityObjectToClipPos(v.vertex);
			    o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
			    return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 lightNormal = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 color = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(lightNormal,i.worldNormal));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				color += ambient;
				return fixed4(color,1);
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
