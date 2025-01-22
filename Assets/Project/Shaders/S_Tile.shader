Shader "Unlit/S_Tile"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Mask ("Sprite Mask", 2D) = "white" {}
        [HDR]_Color ("Tint", Color) = (1,1,1,1)
        
        _Rect ("Rect Display", Vector) = (0,0,1,1)
        
        [Header(Pulse)]
        [Space(10)]
        _IsSelected ("Is Selected", Range(0,1)) = 0
        _PulseRadius ("Pulse Radius", Range(-2,2)) = 0
        _PulseSpeed ("Pulse Speed", Float) = 0.5
        
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
            sampler2D _Mask;
            float4 _Color;
            float4 _MainTex_ST;
            float4 _Mask_ST;
            float _IsSelected;
            float _PulseRadius;
            float _PulseSpeed;

            float4 _Rect;

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
                float mask = tex2D(_Mask,IN.uv).r;

                float saturation = Saturation(diffuse, 0);

                float pulse = step(saturate(frac((distance(localuv,float2(0.5,0.5))*saturation)/_PulseRadius - _Time.y*_PulseSpeed)),0.2);
                
                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                cooldownMask.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                clip (cooldownMask.a - 0.001);
                #endif

                float4 isPulsating = lerp(0,(pulse*diffuse.a) * _Color* 0.3, _IsSelected);
                
                float4 result = diffuse + mask * _Color + isPulsating;
                return result;

            }
        ENDHLSL
        }
    }
}
