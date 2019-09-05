export prior_mean, prior_variance, prior_mean_var
export prior_sample, prior_loglikelihood

export encoder_mean, encoder_variance, encoder_mean_var
export encoder_sample, encoder_loglikelihood

export decoder_mean, decoder_variance, decoder_mean_var
export decoder_sample, decoder_loglikelihood

abstract type AbstractVAE{T<:Real} <: AbstractGM end


# PRIOR

prior_mean_var(m::AbstractVAE) = error("Not implemented")
prior_mean(m::AbstractVAE) = prior_mean_var(m)[1]
prior_variance(m::AbstractVAE) = prior_mean_var(m)[2]

function prior_sample(m::AbstractVAE{T}) where T
    (μ, σ) = prior_mean_var(m)
    μ .+ randn(T, m.zsize) .* sqrt.(σ)
end

function prior_loglikelihood(m::AbstractVAE, z::AbstractArray)
    (μz, σz) = prior_mean_var(m)
    -sum((z - μz).^2 ./ σz, dims=1)
end

function prior_sample(m::AbstractVAE{T}) where T
    (μz, σz) = prior_mean_var(m)
    μz .+ sqrt.(σz) .* randn(T, m.zsize)
end


# ENCODER

encoder_mean_var(m::AbstractVAE, x::AbstractArray) = error("Not implemented")
encoder_mean(m::AbstractVAE, x::AbstractArray) = encoder_mean_var(m, x)[1]
encoder_variance(m::AbstractVAE, x::AbstractArray) = encoder_mean_var(m, x)[2]

function encoder_loglikelihood(m::AbstractVAE, x::AbstractArray, z::AbstractArray)
    (μz, σz) = encoder_mean_var(m, x)
    -sum((z - μz).^2 ./ σz, dims=1)
end

function encoder_sample(m::AbstractVAE{T}, μz::AbstractArray, σz::AbstractArray) where T
    μz .+ sqrt.(σz) .* randn(T, m.zsize)
end

function encoder_sample(m::AbstractVAE{T}, x::AbstractArray) where T
    (μz, σz) = encoder_mean_var(m, x)
    encoder_sample(m, μz, σz)
end


# DECODER

decoder_mean_var(m::AbstractVAE, z::AbstractArray) = error("Not implemented")
decoder_mean(m::AbstractVAE, z::AbstractArray) = decoder_mean_var(m, z)[1]
decoder_variance(m::AbstractVAE, z::AbstractArray) = decoder_mean_var(m, z)[2]

function decoder_loglikelihood(m::AbstractVAE, x::AbstractArray, z::AbstractArray)
    @assert size(x, 1) == m.xsize
    @assert size(z, 1) == m.zsize
    (μx, σe) = decoder_mean_var(m, z)
    -dropdims(sum((x - μx).^2 ./ σe, dims=1), dims=1)
end

function decoder_sample(m::AbstractVAE{T}, μx::AbstractArray, σe::AbstractArray) where T
    μx .+ sqrt.(σe) .* randn(T, m.xsize)
end

function decoder_sample(m::AbstractVAE{T}, z::AbstractArray) where T
    (μx, σe) = decoder_mean_var(m, z)
    decoder_sample(m, μx, σe)
end
