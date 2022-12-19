// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "CZY/Diffuse Vertex-Level" {
    Properties{
        _Diffuse ("Diffuse",Color) = (1,1,1,1)
    }

    SubShader{
        Pass{
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            
            float4 _Diffuse;
            
            struct a2v{
                float4 pos : POSITION;
                float3 normal: NORMAL;
            };
            
            struct v2f{
                float4 pos : SV_POSITION;
                fixed3 color : TEXCOORD0;
            };
            
            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                fixed3 worldNormal = normalize(mul(v.normal,(fixed3x3)unity_WorldToObject));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                o.color = _Diffuse*_LightColor0.rgb* saturate(dot(worldNormal,worldLight));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                o.color = o.color + ambient;
                return o;
            };
            
            fixed4 frag(v2f i):SV_TARGET{
                return fixed4(i.color,1);
            }
            
            
            ENDCG
        }
    }	
    
    Fallback "Diffuse"
}
