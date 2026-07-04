#ifndef LLAMA_BINDINGS_H
#define LLAMA_BINDINGS_H
#include <stdint.h>
#include <stddef.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef void* llama_model_handle;
typedef void* llama_context_handle;
llama_model_handle nomad_load_model(const char* path, int n_gpu_layers, int use_mmap, int use_mlock);
llama_context_handle nomad_create_context(llama_model_handle model, int n_ctx, int n_batch, int n_threads, int embedding);
char* nomad_generate(llama_context_handle ctx, const char* prompt, float temp, float top_p, int top_k, float repeat_penalty, int seed);
int nomad_tokenize(llama_context_handle ctx, const char* text, int** tokens_out);
char* nomad_detokenize(llama_context_handle ctx, const int* tokens, int n_tokens);
float* nomad_embed(llama_context_handle ctx, const char* text, int* n_embd_out);
float* nomad_get_logits(llama_context_handle ctx, int* n_logits_out);
void nomad_unload_model(llama_model_handle model);
void nomad_free(void* ptr);
#ifdef __cplusplus
}
#endif
#endif
