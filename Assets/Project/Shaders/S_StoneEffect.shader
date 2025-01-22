Shader "Unlit/S_Tile"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [HDR]_Color ("Tint", Color) = (1,1,1,1)
        
        _Rect ("Rect Display", Vector) = (0,0,1,1)
        
        [Header(Pulse)]
        [Space(10)]
        _Slide("Slide",float) = 1
        _Rotation("Rotation",float) = 1
        _Width("Width",float) = 1
        
        [Space(50)]
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "Utils/Utils.hlsl"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 uv  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _Color;
            float4 _MainTex_ST;
        
            float4 _Rect;

            float _Slide;
            float _Rotation;
            float _Width;

            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);

                o.uv = v.uv;

                o.color = v.color;
                return o;
            }

            float4 frag(v2f IN) : SV_Target
            {
                float2 localuv = (IN.uv - _Rect.xy) / _Rect.zw;
                float4 diffuse = tex2D(_MainTex,IN.uv) * IN.color;

                float saturation = Saturation(diffuse, 0);

                float2 mask = saturation* localuv + Remap(_Slide,float2(0,1),float2(-1,1));

                float fakeReflex = step(distance(Rotate_Radians(mask,float2(0.5,0.5),_Rotation).x,0.5),_Width);
                
                float3 color = diffuse.rgb * fakeReflex*_Color + diffuse.rgb* IN.color.rgb ;
                float alpha = diffuse.a * IN.color.a;
                
                return float4(color,alpha);
            }
        ENDHLSL
        }
    }
}
