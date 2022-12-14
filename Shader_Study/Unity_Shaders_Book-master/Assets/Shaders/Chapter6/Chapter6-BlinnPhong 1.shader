// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CZY/Blinn-Phong" {
	Properties{
	    _Diffuse("Diffuse",COLOR) = (1,1,1,1)
	    _Specular("Specular",COLOR) = (1,1,1,1)
	    _Gloss("Gloss",float) = 20
	}
	SubShader{
	    Pass{
	    Tags { "LightMode"="ForwardBase" }
	        CGPROGRAM
	       #pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
	        
	        struct a2v{
	            float4 pos:POSITION;
	            float3 normal:NORMAL;
	        };
	        
	        struct v2f{
	            float4 pos:SV_POSITION;
	            float4 worldPos:TEXCOORD1;
	            float3 normal:TEXCOORD0;
	        };
	        fixed4 _Diffuse;
	        fixed4 _Specular;
	        float _Gloss;
	        
	        
	        v2f vert(a2v v){
	            v2f o;
	            o.pos = UnityObjectToClipPos(v.pos);
	            o.normal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
	            o.worldPos = mul(unity_ObjectToWorld,v.pos);
	            /*fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
	            fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
	            fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	            fixed3 diffuse = _Diffuse*_LightColor0*saturate(dot(worldNormal,worldLight));
	            
	            //注意这里的worldLight为负
	            fixed3 reflectDir = normalize( reflect(-worldLight,worldNormal));
	            fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.pos).xyz);
	            fixed3 specular = _Specular*_LightColor0*pow( saturate(dot(reflectDir,viewDir)),_Gloss);
	            o.color = ambient + diffuse + specular;*/
	            return o;
	        };
	        
	        fixed4 frag(v2f i):SV_TARGET{
	      
	            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
	            fixed3 worldNormal = normalize(i.normal);
	            fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	            fixed3 diffuse = _Diffuse*_LightColor0*saturate(dot(worldNormal,worldLight));
	            
	            //注意这里需要顶点在世界坐标中位置 
	            fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
	            
	            //需要注意 viewDir是看向摄像机的地方 worldLiht是看向光源的地方，两者应该相加
 	            fixed3 halfDir = normalize(viewDir+worldLight);
	            fixed3 specular = _Specular*_LightColor0*pow( saturate(dot(i.normal,halfDir)),_Gloss);
            	fixed3 color =  ambient + diffuse + specular;
	            return fixed4(color,0);
	        };
	        
	        ENDCG
	    }
	   
	}
	FallBack "Specular"
}
