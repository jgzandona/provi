#!/bin/bash


CHECKPOINT_MODELS=(
    #"https://civitai.com/api/download/models/320428"
    "https://huggingface.co/stabilityai/sdxl-turbo/resolve/main/sd_xl_turbo_1.0.safetensors?download=true"
)


CONTROLNET_MODELS=(
    "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors"
)

function get_instantID_node(){
#instala comfyui 
apt install unzip
unzip -v   
cd /workspace
git clone "https://github.com/comfyanonymous/ComfyUI"
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install -U --pre xformers
cd /workspace/ComfyUI
pip install -r requirements.txt

#instala manager
cd "/workspace/ComfyUI/custom_nodes"
git clone "https://github.com/ltdrdata/ComfyUI-Manager.git"
git clone "https://github.com/cubiq/ComfyUI_InstantID.git"


#BAIXA E UNZIP NOS ARQUIVOS OMNX
ANTELOPEV_DIR="/workspace/ComfyUI/models/insightface/models"
mkdir $ANTELOPEV_DIR
cd $ANTELOPEV_DIR
ANTELOPEV_MODEL="https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2.zip"
wget $ANTELOPEV_MODEL
unzip antelopev2.zip
rm antelopev2.zip


#BAIXA INSTANTID
provisioning_get_models "/workspace/ComfyUI/models/instantid"   https://huggingface.co/InstantX/InstantID/resolve/main/ip-adapter.bin



#BAIXA CONTROLNET
provisioning_get_models \
"/workspace/ComfyUI/models/controlnet" \
 $CONTROLNET_MODELS



provisioning_get_models "/workspace/ComfyUI/models/checkpoints" \
 $CHECKPOINT_MODELS


 apt update
 apt install psmisc

}


function provisioning_download() {
    wget -qnc --content-disposition --show-progress -e dotbytes="${3:-4M}" -P "$2" "$1"
}
# Faz a verificacao para baixar o modelo e colocar na pasta
function provisioning_get_models() {
    if [[ -z $2 ]]; then return 1; fi
    dir="$1"
    mkdir -p "$dir"
    shift
    if [[ $DISK_GB_ALLOCATED -ge $DISK_GB_REQUIRED ]]; then
        arr=("$@")
    else
        printf "WARNING: Low disk space allocation - Only the first model will be downloaded!\n"
        arr=("$1")
    fi
    
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

get_instantID_node